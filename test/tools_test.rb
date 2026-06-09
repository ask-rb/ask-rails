# frozen_string_literal: true

require_relative "test_helper"

class ToolsTest < Minitest::Test
  def test_read_file_defines_correct_params
    tool = Ask::Rails::Tools::ReadFile.new
    assert_equal "read_file", tool.name
    assert tool.parameters.key?(:path)
  end

  def test_run_command_defines_correct_params
    tool = Ask::Rails::Tools::RunCommand.new
    assert_equal "run_command", tool.name
    assert tool.parameters.key?(:command)
  end

  def test_search_codebase_defines_correct_params
    tool = Ask::Rails::Tools::SearchCodebase.new
    assert_equal "search_codebase", tool.name
    assert tool.parameters.key?(:pattern)
  end

  def test_read_routes_has_no_required_params
    tool = Ask::Rails::Tools::ReadRoutes.new
    assert_equal "read_routes", tool.name
  end

  def test_tool_inherits_from_ask_tool
    assert Ask::Rails::Tools::ReadFile.ancestors.include?(Ask::Tool)
    assert Ask::Rails::Tools::RunCommand.ancestors.include?(Ask::Tool)
    assert Ask::Rails::Tools::SearchCodebase.ancestors.include?(Ask::Tool)
    assert Ask::Rails::Tools::ReadRoutes.ancestors.include?(Ask::Tool)
  end
end
