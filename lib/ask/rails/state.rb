# frozen_string_literal: true

require "active_record"

module Ask
  module Rails
    # ActiveRecord-backed state adapter for the ask_state table.
    #
    # Used by ask-graph (workflow checkpoints) and any other ask component
    # that needs durable key-value storage in the Rails database. Works with
    # any Rails database adapter — PostgreSQL, MySQL, SQLite — because the
    # +value+ column is a portable JSON type.
    #
    # @example
    #   store = Ask::Rails::State.new
    #   store.set("checkpoint:1", { completed: true })
    #   store.get("checkpoint:1")  # => { "completed" => true }
    class State < ::Ask::State::Adapter
      class Record < ::ActiveRecord::Base
        self.table_name = "ask_state"
      end

      def get(key)
        record = Record.find_by(key: key)
        return nil unless record
        return nil if record.expires_at && record.expires_at <= Time.current

        record.value
      end

      def set(key, value, ttl: nil)
        record = Record.find_or_initialize_by(key: key)
        record.value = value
        record.expires_at = ttl ? Time.current + ttl : nil
        record.save!
        value
      end

      def delete(key)
        Record.where(key: key).delete_all
      end

      def clear
        Record.delete_all
      end

      def keys(pattern: nil)
        scope = Record.all
        if pattern
          like = self.class.glob_to_like(pattern)
          scope = scope.where("key LIKE ?", like)
        end
        scope.pluck(:key)
      end

      def set_if_not_exists(key, value, ttl: nil)
        return false if exists?(key)

        set(key, value, ttl: ttl)
        true
      end

      # Ordered lists — stored as an array in the value column.
      # Required by Ask::Agent::Persistence::Base for session indexes.

      def list_append(key, value, max_length: nil)
        entries = list_range(key)
        entries << value
        entries = entries.last(max_length) if max_length
        set(key, entries)
      end

      def list_range(key, start = 0, stop = -1)
        entries = get(key)
        return [] unless entries.is_a?(Array)

        entries[start..stop] || []
      end

      def list_remove(key, value)
        entries = get(key)
        return 0 unless entries.is_a?(Array)

        before = entries.size
        entries.delete(value)
        set(key, entries)
        before - entries.size
      end
    end
  end
end
