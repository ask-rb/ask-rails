# frozen_string_literal: true

require_relative "test_helper"

class SchemaGraphTest < Minitest::Test
  def setup
    @tool = Ask::Rails::Tools::SchemaGraph.new
  end

  def test_defines_correct_name
    assert_equal "schema_graph", @tool.name
  end

  def test_defines_detail_param
    assert @tool.parameters.key?(:detail)
  end

  def test_inherits_from_ask_rails_tool
    assert Ask::Rails::Tools::SchemaGraph.ancestors.include?(Ask::Rails::Tool)
  end

  def test_returns_hash
    result = @tool.execute(detail: "all")
    assert_instance_of Hash, result
  end

  def test_returns_summary_with_counts
    result = @tool.execute(detail: "all")
    assert result.key?(:summary)
    summary = result[:summary]
    assert_kind_of Integer, summary[:model_count]
    assert_kind_of Integer, summary[:table_count]
    assert_kind_of Integer, summary[:association_count]
  end

  def test_detail_models_returns_models_key
    result = @tool.execute(detail: "models")
    assert result.key?(:models)
    assert_kind_of Array, result[:models], "models should be an array (possibly empty)"
  end

  def test_detail_associations_returns_associations_key
    result = @tool.execute(detail: "associations")
    assert result.key?(:associations)
    assert_kind_of Array, result[:associations], "associations should be an array (possibly empty)"
  end

  def test_detail_tables_returns_tables_key
    result = @tool.execute(detail: "tables")
    assert result.key?(:tables)
    assert_kind_of Hash, result[:tables], "tables should be a hash (possibly empty)"
  end

  def test_always_returns_keys
    result = @tool.execute(detail: "all")
    assert result.key?(:models), "all detail should include models"
    assert result.key?(:associations), "all detail should include associations"
    assert result.key?(:tables), "all detail should include tables"
  end

  def test_executes_without_crashing
    # Should never raise, even without a real Rails app
    result = @tool.execute
    assert_instance_of Hash, result
  end
end
