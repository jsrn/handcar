require "handcar/sqlite_model"

module Handcar
  class Controller
    include Handcar::Model

    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      text = self.send(action)
      r = get_response
      if r
        [r.status, r.headers, [r.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'},
         [text].flatten]
      end
    end

    def self.action(act, rp = {})
      proc { |e| self.new(e).dispatch(act, rp) }
    end

    def env
      @env
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def render(view_name, locals = {})
      instance_variables.each do |variable|
        locals[variable] = instance_variable_get(variable)
      end

      view = View.new(self, view_name, locals)

      response(view.result)
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, '')
      Handcar.to_underscore(klass)
    end

    def response(text, status = 200, headers = { 'Content-Type' => 'text/html'})
      raise 'Already responded!' if @response

      a = [text].flatten
      @response = Rack::Response.new(a, status, headers)
    end

    def get_response
      if @response
        @response
      else
        render(action)
      end
    end

    private

    def params
      request.params.merge(@routing_params)
    end

    def action
      params['action']
    end
  end
end
