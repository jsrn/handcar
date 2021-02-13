require 'sqlite3'
require 'handcar/util'

module Handcar
  module Model
    class SQLite
      def self.database
        @database ||= SQLite3::Database.new('test.db')
      end

      def self.database=(database)
        @database = database
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
        fields = @hash.map do |k, v|
          "#{k}=#{self.class.to_sql(v)}"
        end.join ","
        self.class.database.execute <<SQL
UPDATE #{self.class.table}
SET #{fields}
WHERE id = #{@hash["id"]}
SQL
        true
      end

      def save
        self.save! rescue false
      end

      def method_missing(method, *args, &block)
        if self.class.schema.keys.include?(method.to_s)
          self[method]
        else
          super(method, *args, &block)
        end
      end

      def respond_to_missing?(method, *args, &block)
        if schema.keys.include?(method.to_s)
          true
        else
          super(method, *args, &block)
        end
      end

      def self.to_sql(val)
        case val
        when NilClass
          'null'
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise StandardError.new, "Can't change #{val.class} to SQL!"
        end
      end

      def self.all
        data = database.execute(<<SQL)
SELECT #{schema.keys.join ","} FROM #{table};
SQL
        data.map { |row| self.new(Hash[schema.keys.zip(row)]) }
      end

      def self.create(values)
        values.delete('id')
        keys = schema.keys - ['id']
        vals = keys.map do |key|
          values[key] ? to_sql(values[key]) : 'null'
        end

        query = <<SQL
INSERT INTO #{table} (#{keys.join ","}) VALUES (#{vals.join ","});
SQL
        database.execute(query)
        raw_vals = keys.map { |k| values[k] }
        data = Hash[keys.zip raw_vals]
        sql = "SELECT last_insert_rowid();"
        data["id"] = database.execute(sql)[0][0]
        self.new data
      end

      def self.count
        database.execute(<<SQL)[0][0]
SELECT COUNT(*) FROM #{table}
SQL
      end

      def self.find(id)
        row = database.execute(<<SQL)
SELECT #{schema.keys.join ","} FROM #{table} WHERE id = #{id};
SQL
        data = Hash[schema.keys.zip row[0]]
        self.new data
      end

      def self.table
        "#{Handcar.to_underscore(name)}s"
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        database.table_info(table) do |row|
          @schema[row['name']] = row['type']
        end
        @schema
      end
    end
  end
end