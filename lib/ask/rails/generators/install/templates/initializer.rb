# frozen_string_literal: true

# Ask Agent Configuration
# ========================
#
# API keys are resolved automatically by Ask::Auth:
#   - Environment variables: OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.
#   - Rails credentials: rails credentials:edit → ask.openai, ask.anthropic
#   - ~/.ask/credentials.yml
#
# See https://github.com/ask-rb/ask-auth for details.

# Shared key-value state store for agent sessions and graph checkpoints.
# Uses the ask_state table created by the migration.
ASK_STATE = Ask::State::PostgreSQL.new(
  table_name: :ask_state
)

Ask::Agent.configure do |config|
  # State persistence for agent sessions
  config.state = ASK_STATE

  # Audit log for session events
  config.audit_log = { adapter: :active_record }

  # config.default_model = "gpt-4o"
end
