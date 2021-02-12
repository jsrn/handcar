require './config/application'

app = MyApp::Application.new

use Rack::ContentType

app.route do
  match 'greetings/show', default: { 'controller' => 'greetings', 'action' => 'show' }
  root 'greetings#index'
end

run app
