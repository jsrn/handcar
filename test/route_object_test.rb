require_relative "test_helper"
require_relative '../lib/handcar/routing'

class RouteObjectTest < Minitest::Test
  def test_root_routes_properly
    routes = Handcar::RouteObject.new
    routes.root 'quotes/index'
    assert_equal 2, routes.rules.length

    root_route = routes.rules.last
    assert_equal 'quotes/index', root_route[:dest]
  end

  def test_specifying_verb
    routes = Handcar::RouteObject.new
    routes.match 'quotes/index', via: 'post'

    route = routes.rules.last
    assert_equal 'post', route[:options][:via]
  end

  def test_resources
    routes = Handcar::RouteObject.new
    routes.resources :greetings

    rules = routes.rules
    rules.shift

    assert_equal 2, rules.length
  end
end
