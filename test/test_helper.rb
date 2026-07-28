# frozen_string_literal: true

# Load paths for local ask-rb gems (prefer local over installed)
ask_rb_root = File.expand_path("../..", __dir__)
%w[ask-core ask-tools ask-tools-shell ask-schema ask-auth ask-instrumentation ask-llm-providers ask-agent ask-rails].each do |gem|
  lib = File.join(ask_rb_root, gem, "lib")
  $LOAD_PATH.unshift lib if File.directory?(lib)
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "rails"
require "active_support"
require "ask/rails"

require "minitest/autorun"
require "mocha/minitest"
