source "https://rubygems.org"

gemspec

# json 3.0 removed the positional-hash argument from JSON.parse, breaking
# ActiveSupport::JSON.decode in Rails 8.1.x.  Pin to < 3 until Rails ships
# a compatible release.
gem "json", "< 3.0"

# Local development — use local paths for ask-rb gems
ask_rb_root = File.expand_path("..", __dir__)
%w[ask-core ask-tools ask-tools-shell ask-schema ask-auth ask-instrumentation ask-llm-providers ask-agent].each do |gem_name|
  gem gem_name, path: File.join(ask_rb_root, gem_name)
end

group :test do
  gem "minitest", "~> 5.25"
  gem "mocha", "~> 3.1"
  gem "rake", "~> 13.0"
  gem "sqlite3", ">= 1.4"
end
