# frozen_string_literal: true

module Ask
  module Rails
    # ActiveRecord model for persisting agent sessions.
    #
    # Created by the +ask_rails:install+ generator. The +ask_sessions+ table
    # stores session state in a JSONB +data+ column, keyed by a unique
    # +session_id+ string.
    #
    # Used automatically when +persistence_adapter+ is configured with the
    # default model class:
    #
    #   Ask::Rails.configure do |config|
    #     config.persistence_adapter = Ask::Rails::Persistence.new
    #   end
    #
    # Without +model_class:+, +Persistence+ defaults to +Ask::Rails::Session+.
    class Session < ActiveRecord::Base
      self.table_name = "ask_sessions"
    end
  end
end
