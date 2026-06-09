# frozen_string_literal: true

require_relative "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    Ask::Rails.send(:remove_instance_variable, :@configuration) if Ask::Rails.instance_variable_defined?(:@configuration)
  rescue NameError
  end

  def test_default_values
    config = Ask::Rails::Configuration.new
    assert_equal "gpt-4o", config.default_model
    assert_equal 25, config.max_turns
    assert_nil config.system_prompt
    assert_equal 5, config.tool_concurrency
    assert_nil config.persistence_adapter
    assert_equal [], config.tools
  end

  def test_configurable
    Ask::Rails.configure do |c|
      c.default_model = "claude-sonnet-4"
      c.max_turns = 50
    end
    assert_equal "claude-sonnet-4", Ask::Rails.configuration.default_model
    assert_equal 50, Ask::Rails.configuration.max_turns
  end

  def test_tools_settable
    config = Ask::Rails::Configuration.new
    config.tools = [:tool1, :tool2]
    assert_equal [:tool1, :tool2], config.tools
  end
end
