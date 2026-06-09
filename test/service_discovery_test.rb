# frozen_string_literal: true

require_relative "test_helper"

class ServiceDiscoveryTest < Minitest::Test
  def test_build_system_prompt_with_no_services
    prompt = Ask::Rails::ServiceDiscovery.build_system_prompt([])
    assert_equal "## Available Services", prompt.strip
  end

  def test_build_system_prompt_with_mock_context
    # Create a module that looks like a service context module
    mod = Module.new
    mod.define_singleton_method(:name) { "Ask::GitHub" }
    mod.const_set(:DESCRIPTION, "A test service") rescue nil
    mod.const_set(:DOCS_URL, "https://docs.test.com") rescue nil

    # Try via const_set directly on the module
    mod.instance_variable_set(:@description, "A test service")
    mod.instance_variable_set(:@docs_url, "https://docs.test.com")

    prompt = Ask::Rails::ServiceDiscovery.build_system_prompt([mod])
    assert prompt.is_a?(String)
    assert_includes prompt, "GitHub"  # module name
  end
end
