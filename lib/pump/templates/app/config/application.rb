require "handcar"

$LOAD_PATH << File.join(File.dirname(__FILE__),
  "..",
  "app",
  "controllers")

module MyApp
  class Application < Handcar::Application
  end
end
