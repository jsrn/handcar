module Handcar
  class RouteObject
    attr_reader :rules
    def initialize
      @rules = [{
        regexp: Regexp.new("^/favicon.ico$"),
        vars: {},
        dest: proc { [404, {"Content-Type" => "text/html"}, ["Not Found"]] },
        options: {}
      }]
    end

    def root(*args)
      match "", *args
    end

    def resources(key)
      match key.to_s, default: {"controller" => key.to_s, "action" => "index"}, via: :get
      match "#{key}/:id", default: {"controller" => key.to_s, "action" => "show"}, via: :get
    end

    def match(url, *args)
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}
      dest = nil
      dest = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0

      parts = url.split("/")
      parts.select! { |p| !p.empty? }

      vars = []
      regexp_parts = parts.map { |part|
        if part[0] == ":"
          vars << part[1..]
          "([a-zA-Z0-9]+)"
        elsif part[0] == "*"
          vars << part[1..]
          "(.*)"
        else
          part
        end
      }
      regexp = regexp_parts.join("/")
      @rules.push({
        regexp: Regexp.new("^/#{regexp}$"),
        vars: vars,
        dest: dest,
        options: options
      })
    end

    def check_url(url, verb)
      @rules.each do |r|
        m = r[:regexp].match(url)
        next if m.nil?

        options = r[:options]
        next if options[:via] && options[:via].to_sym != verb.downcase.to_sym

        params = options[:default].dup

        r[:vars].each_with_index do |v, i|
          params[v] = m.captures[i]
        end

        if r[:dest]
          return get_dest(r[:dest], params)
        else
          controller = params["controller"]
          action = params["action"]
          return get_dest(controller.to_s +
                              "##{action}", params)
        end
      end

      nil
    end

    def get_dest(dest, routing_params = {})
      return dest if dest.respond_to?(:call)

      if dest =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        con = Object.const_get("#{name}Controller")
        return con.action($2, routing_params)
      end
      raise "No destination: #{dest.inspect}!"
    end
  end
end
