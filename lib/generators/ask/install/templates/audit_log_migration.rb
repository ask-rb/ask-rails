# frozen_string_literal: true

class CreateAskAuditLogs < ActiveRecord::Migration[8.1]
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
