require "sqlite3"
require "handcar/util"

module Handcar
  module Model
    class SQLite
      def self.database
        @database ||= SQLite3::Database.new("test.db")
      end

      class << self
        attr_writer :database
      end

      def initialize(data = {})
        @hash = data
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash["id"]
          self.class.create(@hash)
          return true
        end
        fields = @hash.map { |k, v|
          "#{k}=#{self.class.to_sql(v)}"
        }.join ","
        self.class.database.execute <<~SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{@hash["id"]}
        SQL
        true
      end

      def save
        save!
      rescue
        false
      end

      def method_missing(method, *args, &block)
        if self.class.schema.key?(method.to_s)
          self[method]
        elsif method.to_s.end_with?("=")
          potential_attribute = method.to_s[0..-2]
          if self.class.schema.key?(potential_attribute)
            self[potential_attribute] = args.first
          else
            super(method, *args, &block)
          end
        else
          super(method, *args, &block)
        end
      end

      def respond_to_missing?(method, *args, &block)
        if schema.key?(method.to_s)
          true
        elsif method.to_s.end_with?("=") && schema.key?(method.to_s[0..-2])
          true
        else
          super(method, *args, &block)
        end
      end

      def self.to_sql(val)
        case val
        when NilClass
          "null"
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise StandardError.new, "Can't change #{val.class} to SQL!"
        end
      end

      def self.all
        data = database.execute(<<~SQL)
          SELECT #{schema.keys.join ","} FROM #{table};
        SQL
        data.map { |row| new(Hash[schema.keys.zip(row)]) }
      end

      def self.create(values)
        values.delete("id")
        keys = schema.keys - ["id"]
        vals = keys.map { |key|
          values[key] ? to_sql(values[key]) : "null"
        }

        query = <<~SQL
          INSERT INTO #{table} (#{keys.join ","}) VALUES (#{vals.join ","});
        SQL
        database.execute(query)
        raw_vals = keys.map { |k| values[k] }
        data = Hash[keys.zip raw_vals]
        sql = "SELECT last_insert_rowid();"
        data["id"] = database.execute(sql)[0][0]
        new data
      end

      def self.count
        database.execute(<<~SQL)[0][0]
          SELECT COUNT(*) FROM #{table}
        SQL
      end

      def self.find(id)
        row = database.execute(<<~SQL)
          SELECT #{schema.keys.join ","} FROM #{table} WHERE id = #{id};
        SQL
        data = Hash[schema.keys.zip row[0]]
        new data
      end

      def self.table
        "#{Handcar.to_underscore(name)}s"
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        database.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema
      end
    end
  end
end
