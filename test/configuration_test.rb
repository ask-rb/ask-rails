# frozen_string_literal: true

require_relative "test_helper"

class ConfigurationTest < Minitest::Test
  def test_default_values
    config = Ask::Rails::Configuration.new
    assert_equal "gpt-4o", config.default_model
    assert_equal 25, config.max_turns
    assert_nil config.system_prompt
    assert_equal 5, config.tool_concurrency
    assert_nil config.persistence_adapter
    assert_equal [], config.tools
  end

  def test_defaults_are_mutable
    config = Ask::Rails::Configuration.new
    config.default_model = "claude-sonnet-4"
    assert_equal "claude-sonnet-4", config.default_model
  end

  def test_tools_are_settable
    config = Ask::Rails::Configuration.new
    config.tools = [:tool1, :tool2]
    assert_equal [:tool1, :tool2], config.tools
  end

  def test_max_turns_clamping
    config = Ask::Rails::Configuration.new
    config.max_turns = 100
    assert_equal 100, config.max_turns
  end
end
