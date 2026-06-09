# Changelog

## 0.1.0 (2026-06-10)

### Added

- Railtie — `Ask::Rails::Railtie` configures RubyLLM and discovers tools/services on boot
- Configuration — `Ask::Rails::Configuration` with `default_model`, `max_turns`, `system_prompt`, `tool_concurrency`
- Session Factory — `Ask::Rails.agent_session` creates pre-configured `Ask::Agent::Session`
- Service Discovery — auto-discovers installed `ask-*` service gems, injects context into system prompt
- AR Persistence — `Ask::Rails::Persistence` saves/loads session state to database
- Rails Tools — `ReadFile`, `RunCommand`, `SearchCodebase`, `ReadRoutes` (Rails.root-aware)
- Generators — `rails generate ask_rails:install` creates migration, initializer, `app/tools/`
- Dependencies: rails >= 7.1, ask-tools, ask-tools-shell, ask-agent, ask-auth
