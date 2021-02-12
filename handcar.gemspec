
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "handcar/version"

Gem::Specification.new do |spec|
  spec.name          = "handcar"
  spec.version       = Handcar::VERSION
  spec.authors       = ["jsrn"]
  spec.email         = ["jsrn@hey.com"]

  spec.summary       = %q{A Rack based web framework.}
  spec.description   = %q{A Rack based web framework, with some bugs..}
  spec.homepage      = "https://jsrn.net"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rack-test", "~> 1.1"

  spec.add_runtime_dependency "rack", "~> 2.2.3"
  spec.add_runtime_dependency "erubis", "~> 2.7"
  spec.add_runtime_dependency "multi_json", "~> 1.15"
  spec.add_runtime_dependency "sqlite3", "~> 1.4.2"

  spec.executables = ["handcar"]
end
