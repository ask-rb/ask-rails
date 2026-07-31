# frozen_string_literal: true

# Migration for ask-agent's audit log table.
# This table records session events (tool calls, errors, token usage, etc.)
# from every agent that has audit_log configured.
class CreateAskAuditLogs < ActiveRecord::Migration[<%= migration_version %>]
  def change
    create_table :ask_audit_logs, if_not_exists: true do |t|
      t.string :session_id, null: false
      t.string :event_type, null: false
      t.jsonb :data, default: {}
      t.datetime :timestamp, null: false
      t.timestamps

      t.index [:session_id, :event_type]
      t.index :timestamp
    end
  end
end
