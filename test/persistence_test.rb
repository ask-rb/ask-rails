# frozen_string_literal: true

require_relative "test_helper"

class PersistenceTest < Minitest::Test
  def test_persistence_initializes
    p = Ask::Rails::Persistence.new
    assert p
  end

  def test_save_requires_active_record
    skip "Requires ActiveRecord"
  end
end
