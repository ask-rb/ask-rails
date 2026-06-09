# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ask/rails/version"
require "ask/rails/configuration"
require "ask/rails/persistence"
require "ask/rails/tool"
require "ask/rails/tools/read_file"
require "ask/rails/tools/run_command"
require "ask/rails/tools/search_codebase"
require "ask/rails/tools/read_routes"
require "ask/rails/service_discovery"

require "minitest/autorun"
require "mocha/minitest"
