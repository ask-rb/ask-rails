# frozen_string_literal: true

require_relative "test_helper"

class PersistenceTest < Minitest::Test
  def test_persistence_initializes
    p = Ask::Rails::Persistence.new
    assert p
  end

  def test_save_requires_model_class
    p = Ask::Rails::Persistence.new
    assert_raises(RuntimeError) { p.save("s1", {}) }
  end

  def test_load_requires_model_class
    p = Ask::Rails::Persistence.new
    assert_raises(RuntimeError) { p.load("s1") }
  end

  def test_delete_requires_model_class
    p = Ask::Rails::Persistence.new
    assert_raises(RuntimeError) { p.delete("s1") }
  end

  def test_list_requires_model_class
    p = Ask::Rails::Persistence.new
    assert_raises(RuntimeError) { p.list }
  end

  def test_model_class_as_constructor_arg
    p = Ask::Rails::Persistence.new(model_class: String)
    assert p
  end

  def test_persistence_interface
    p = Ask::Rails::Persistence.new
    assert_respond_to p, :save
    assert_respond_to p, :load
    assert_respond_to p, :delete
    assert_respond_to p, :list
  end
end
