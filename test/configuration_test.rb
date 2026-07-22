# frozen_string_literal: true

require_relative "test_helper"

class ConfigurationTest < Minitest::Test
  def test_default_values
    config = Ask::Rails::Configuration.new
    assert_equal "gpt-4o", config.default_model
    assert_equal 25, config.max_turns
    assert_nil config.system_prompt
    assert_equal 5, config.tool_concurrency
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

  def test_max_turns_settable
    config = Ask::Rails::Configuration.new
    config.max_turns = 100
    assert_equal 100, config.max_turns
  end

  def test_system_prompt_settable
    config = Ask::Rails::Configuration.new
    config.system_prompt = "You are a helpful assistant"
    assert_equal "You are a helpful assistant", config.system_prompt
  end

  def test_persistence_adapter_settable
    config = Ask::Rails::Configuration.new
    config.persistence_adapter = :memory
    assert_equal :memory, config.persistence_adapter
  end

  def test_tool_concurrency_settable
    config = Ask::Rails::Configuration.new
    config.tool_concurrency = 10
    assert_equal 10, config.tool_concurrency
  end

  def test_current_user_defaults_to_nil
    config = Ask::Rails::Configuration.new
    assert_nil config.current_user
  end

  def test_current_user_settable
    config = Ask::Rails::Configuration.new
    config.current_user = -> { { id: 1 } }
    assert_equal 1, config.current_user.call[:id]
  end
end
