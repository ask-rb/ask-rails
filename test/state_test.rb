# frozen_string_literal: true

require_relative "test_helper"

require "active_record"
require "sqlite3"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :ask_state do |t|
    t.string :key, null: false
    t.json :value, null: false, default: {}
    t.datetime :expires_at
    t.timestamps

    t.index :key, unique: true
    t.index :expires_at
  end
end

class StateTest < Minitest::Test
  def setup
    Ask::Rails::State.new.clear
  end

  def test_set_and_get
    store = Ask::Rails::State.new
    store.set("key:1", { completed: true })

    assert_equal({ "completed" => true }, store.get("key:1"))
  end

  def test_get_missing_key_returns_nil
    store = Ask::Rails::State.new
    assert_nil store.get("missing")
  end

  def test_set_overwrites_existing_key
    store = Ask::Rails::State.new
    store.set("key:1", { v: 1 })
    store.set("key:1", { v: 2 })

    assert_equal({ "v" => 2 }, store.get("key:1"))
  end

  def test_delete_removes_key
    store = Ask::Rails::State.new
    store.set("key:1", { v: 1 })
    store.delete("key:1")

    assert_nil store.get("key:1")
  end

  def test_exists
    store = Ask::Rails::State.new
    refute store.exists?("key:1")

    store.set("key:1", { v: 1 })
    assert store.exists?("key:1")
  end

  def test_expiry
    store = Ask::Rails::State.new
    store.set("key:1", { v: 1 }, ttl: -1)

    assert_nil store.get("key:1")
    refute store.exists?("key:1")
  end

  def test_clear
    store = Ask::Rails::State.new
    store.set("key:1", { v: 1 })
    store.set("key:2", { v: 2 })
    store.clear

    assert_nil store.get("key:1")
    assert_nil store.get("key:2")
  end

  def test_keys
    store = Ask::Rails::State.new
    store.set("session:1", { v: 1 })
    store.set("session:2", { v: 2 })
    store.set("checkpoint:1", { v: 3 })

    assert_equal %w[session:1 session:2 checkpoint:1].sort, store.keys.sort
    assert_equal %w[session:1 session:2].sort, store.keys(pattern: "session:*").sort
  end

  def test_set_if_not_exists
    store = Ask::Rails::State.new
    assert store.set_if_not_exists("key:1", { v: 1 })
    refute store.set_if_not_exists("key:1", { v: 2 })

    assert_equal({ "v" => 1 }, store.get("key:1"))
  end

  def test_list_append_and_range
    store = Ask::Rails::State.new
    store.list_append("sessions", "a")
    store.list_append("sessions", "b")
    store.list_append("sessions", "c")

    assert_equal %w[a b c], store.list_range("sessions")
    assert_equal %w[b c], store.list_range("sessions", 1, -1)
  end

  def test_list_append_with_max_length_trims
    store = Ask::Rails::State.new
    5.times { |i| store.list_append("sessions", "item#{i}", max_length: 3) }

    assert_equal %w[item2 item3 item4], store.list_range("sessions")
  end

  def test_list_remove
    store = Ask::Rails::State.new
    store.list_append("sessions", "a")
    store.list_append("sessions", "b")
    store.list_append("sessions", "a")

    assert_equal 2, store.list_remove("sessions", "a")
    assert_equal %w[b], store.list_range("sessions")
  end

  def test_list_range_on_missing_key_returns_empty
    store = Ask::Rails::State.new
    assert_equal [], store.list_range("missing")
  end
end
