require_relative "test_helper"

class TestApp < Handcar::Application; end

class HandcarAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    app = TestApp.new

    app.route do
      destination = proc { [200, {"Content-Type" => "text/html"}, ["Hello, world!"]] }
      root destination
      match "quotes/create", destination, via: "post"
    end

    app
  end

  def test_request
    get "/"

    assert last_response.ok?
    body = last_response.body
    assert body["Hello"]
  end

  def test_post
    post "/"

    assert last_response.ok?
    body = last_response.body
    assert body["Hello"]
  end

  def test_do_not_support_favicon
    get "/favicon.ico"

    assert last_response.not_found?
  end

  def test_verb_specific_actions
    get "/quotes/create"
    assert last_response.not_found?

    post "/quotes/create"
    assert last_response.ok?
  end
end
