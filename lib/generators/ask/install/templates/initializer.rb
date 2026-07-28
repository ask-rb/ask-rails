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

Ask::Agent.configure do |config|
  # Enable audit logging to the ask_audit_logs table
  # config.audit_log = { adapter: :active_record }

  # Optional: set a default model
  # config.default_model = "gpt-4o"
end
