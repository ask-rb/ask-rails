# frozen_string_literal: true

class CreateAskState < ActiveRecord::Migration[8.1]
  def change
    create_table :ask_state do |t|
      t.string :key, null: false
      t.jsonb :value, null: false, default: {}
      t.datetime :expires_at
      t.timestamps

      t.index :key, unique: true
      t.index :expires_at
    end
  end
end
