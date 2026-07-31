# frozen_string_literal: true

# Migration for ask-rb's shared key-value state table.
# Used by ask-agent (session persistence) and ask-graph (workflow checkpoints).
# This single table serves both components — keys are namespaced by convention.
# The json column type works on PostgreSQL, MySQL, and SQLite.
class CreateAskState < ActiveRecord::Migration[<%= migration_version %>]
  def change
    create_table :ask_state do |t|
      t.string :key, null: false
      t.json :value, null: false, default: {}
      t.datetime :expires_at
      t.timestamps

      t.index :key, unique: true
      t.index :expires_at
    end
  end
end
