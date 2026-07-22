# frozen_string_literal: true

require_relative "test_helper"

class RouteInspectorTest < Minitest::Test
  def setup
    @tool = Ask::Rails::Tools::RouteInspector.new
  end

  def test_defines_correct_name
    assert_equal "route_inspector", @tool.name
  end

  def test_defines_params
    assert @tool.parameters.key?(:controller)
    assert @tool.parameters.key?(:pattern)
    assert @tool.parameters.key?(:verbose)
  end

  def test_inherits_from_ask_rails_tool
    assert Ask::Rails::Tools::RouteInspector.ancestors.include?(Ask::Rails::Tool)
  end

  def test_returns_hash_with_routes_and_count
    result = @tool.execute
    assert_instance_of Hash, result
    assert result.key?(:routes)
    assert result.key?(:count)
    assert_kind_of Array, result[:routes]
    assert_kind_of Integer, result[:count]
  end

  def test_routes_have_required_keys
    result = @tool.execute
    result[:routes].each do |route|
      assert route.key?(:verb), "Route missing verb"
      assert route.key?(:path), "Route missing path"
    end
  end

  def test_executes_without_crashing
    result = @tool.execute
    assert_instance_of Hash, result
  end

  def test_executes_with_pattern_filter
    result = @tool.execute(pattern: "test")
    assert_instance_of Hash, result
    assert result.key?(:routes)
  end

  def test_executes_with_verbose
    result = @tool.execute(verbose: true)
    assert_instance_of Hash, result
    assert result.key?(:routes)
  end
end
