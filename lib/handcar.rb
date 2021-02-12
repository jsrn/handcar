require 'handcar/version'
require 'handcar/routing'
require 'handcar/util'
require 'handcar/dependencies'
require 'handcar/controller'
require 'handcar/sqlite_model'
require 'handcar/view'

module Handcar
  class Application
    def route(&block)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      raise 'No routes!' unless @route_obj

      @route_obj.check_url(env['PATH_INFO'], env['REQUEST_METHOD'])
    end

    def call(env)
      app = get_rack_app(env)

      if app
        app.call(env)
      else
        [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
      end
    end
  end
end
