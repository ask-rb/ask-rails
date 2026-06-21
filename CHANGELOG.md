## 0.2.4 (2026-06-21)

### Added
- `Ask::Rails::Engine` — Rails engine for autoloading and generator discovery
- Skills directory with methodology skills (rails.db_debug, rails.deploy_pipeline, rails.route_trouble)
- Gemspec metadata for Rubygems discovery

# Changelog

## 0.2.0 (2026-06-10)

### Added
- `Ask::Rails::QueryDatabase` — read-only SQL queries via ActiveRecord with auto-LIMIT, 
  binary column handling, and production write guards
- `Ask::Rails::ReadModel` — structured model introspection returning columns, associations,
  validators, and primary keys; supports detail filtering
- `Ask::Rails::ReadLog` — filtered log reading that tail-reads from end of file, supports
  level filtering (ERROR/WARN/INFO/DEBUG), case-insensitive search, and automatically
  detects log rotation files

## 0.1.0 (2026-06-10)

### Added
- Railtie — `Ask::Rails::Railtie` configures and discovers tools/services on boot
- Configuration — `Ask::Rails::Configuration` with `default_model`, `max_turns`, `system_prompt`, `tool_concurrency`
- Session Factory — `Ask::Rails.agent_session` creates pre-configured `Ask::Agent::Session`
- Service Discovery — auto-discovers installed `ask-*` service gems, injects context into system prompt
- AR Persistence — `Ask::Rails::Persistence` saves/loads session state to database
- Rails Tools — `ReadFile`, `RunCommand`, `SearchCodebase`, `ReadRoutes` (Rails.root-aware)
- Generators — `rails generate ask_rails:install` creates migration, initializer, `app/tools/`
- Dependencies: rails >= 7.1, ask-tools, ask-tools-shell, ask-agent, ask-auth
