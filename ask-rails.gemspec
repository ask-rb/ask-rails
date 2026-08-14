require_relative "lib/ask/rails/version"

Gem::Specification.new do |spec|
  spec.name = "ask-rails"
  spec.version = Ask::Rails::VERSION
  spec.authors = ["Kaka Ruto"]
  spec.email = ["kaka@myrrlabs.com"]

  spec.summary = "Rails integration for the ask-rb ecosystem"
  spec.description = "Rails generators, file conventions, and railtie for using ask-agent in Rails apps."
  spec.homepage = "https://github.com/ask-rb/ask-rails"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "ask-agent", ">= 0.40.1"

  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "mocha", "~> 3.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "sqlite3", ">= 1.4"
end
