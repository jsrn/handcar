require 'erubis'

class View
  attr_reader :controller, :view_name, :locals

  def initialize(controller, view_name, locals)
    @controller = controller
    @view_name = view_name
    @locals = locals
  end

  def result
    filename = File.join 'app', 'views', controller.controller_name, "#{view_name}.html.erb"
    template = File.read filename
    eruby = Erubis::Eruby.new(template)
    eruby.result(locals.merge(env: controller.env))
  end
end