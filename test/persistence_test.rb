# frozen_string_literal: true

require_relative "test_helper"

class PersistenceTest < Minitest::Test
  def test_persistence_initializes
    p = Ask::Rails::Persistence.new
    assert p
  end

  def test_model_class_as_constructor_arg
    p = Ask::Rails::Persistence.new(model_class: Hash)
    assert p
  end

  def test_persistence_interface
    p = Ask::Rails::Persistence.new(model_class: Hash)
    assert_respond_to p, :save
    assert_respond_to p, :load
    assert_respond_to p, :delete
    assert_respond_to p, :list
  end

  def test_defaults_to_ask_rails_session_when_available
    # Skip test if constant isn't defined (test env without full Rails)
    unless defined?(Ask::Rails::Session)
      skip "Ask::Rails::Session not loaded in test environment"
    end
    p = Ask::Rails::Persistence.new
    assert_equal Ask::Rails::Session, p.send(:model_class)
  end
end
