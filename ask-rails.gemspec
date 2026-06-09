require_relative "lib/ask/rails/version"

Gem::Specification.new do |spec|
  spec.name = "ask-rails"
  spec.version = Ask::Rails::VERSION
  spec.authors = ["Kaka Ruto"]
  spec.email = ["kaka@anywaye.com"]

  spec.summary = "Rails integration for the ask-rb ecosystem"
  spec.description = "Railtie, AR session persistence, session factory, service gem discovery, and generators."
  spec.homepage = "https://github.com/ask-rb/ask-rails"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "ask-tools", "~> 0.1"
  spec.add_dependency "ask-tools-shell", "~> 0.1"
  spec.add_dependency "ask-agent", "~> 0.1"
  spec.add_dependency "ask-auth", "~> 0.1"

  spec.add_development_dependency "sqlite3", ">= 2.0"
  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "mocha", "~> 3.1"
  spec.add_development_dependency "rake", "~> 13.0"
end
