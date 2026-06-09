# frozen_string_literal: true

require_relative "test_helper"

class ServiceDiscoveryTest < Minitest::Test
  def test_build_system_prompt_with_no_services
    prompt = Ask::Rails::ServiceDiscovery.build_system_prompt([])
    assert_equal "## Available Services", prompt.strip
  end

  def test_build_system_prompt_with_mock_context
    mod = Module.new
    mod.define_singleton_method(:const_defined?) { |_| true }
    mock_description = "A test service"
    mock_docs = "https://docs.test.com"
    mod.define_singleton_method(:const_get) do |name|
      case name
      when :DESCRIPTION then mock_description
      when :DOCS_URL then mock_docs
      else super(name)
      end
    end

    prompt = Ask::Rails::ServiceDiscovery.build_system_prompt([mod])
    assert_includes prompt, "A test service"
    assert_includes prompt, "https://docs.test.com"
  end
end
