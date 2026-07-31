# frozen_string_literal: true

# Ask Configuration
# =================
#
# API keys are resolved automatically by Ask::Auth:
#   - Environment variables: OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.
#   - Rails credentials: rails credentials:edit → ask.openai, ask.anthropic
#   - ~/.ask/credentials.yml
#
# See https://github.com/ask-rb/ask-auth for details.

# Agents
Ask::Agent.configure do |config|
  # Audit log for session events (ask_audit_logs table)
  # config.audit_log = { adapter: :active_record }

  # config.default_model = "gpt-4o"
end

# Workflows (ask-graph)
#
# The graph block is only generated when ask-graph is installed.
# Run `bundle add ask-graph` then `rails generate ask:install` to add it.
if defined?(Ask::Graph)
  # Checkpoint storage for workflow crash recovery — backed by the
  # ask_state table (created by the migration) in your Rails database.
  # Works with any database adapter: PostgreSQL, MySQL, SQLite.
  Ask::Graph.storage = Ask::Rails::State.new

  # Ask::Graph.default_step_timeout 30
  # Ask::Graph.default_workflow_timeout 60
end
