## [0.3.0] — 2026-07-21

### Added

- **Admin chat UI** — Mount `Ask::Rails::Engine` at `/ask` and get a working chat interface with SSE streaming. No generator needed — just mount and go.

  ```
  GET  /ask                    → Chat UI
  POST /ask/sessions           → Create new session
  POST /ask/sessions/:id/messages → Send message (SSE streamed)
  GET  /ask/sessions/:id/messages → Message history
  GET  /ask/sessions/:id/stream  → SSE stream for existing session
  ```

- **`Ask::Rails::ChatController`** — Full controller with actions: `index`, `create`, `message` (SSE streaming), `stream`, `history`, `destroy`. Supports real-time streaming via `Enumerator` + `text/event-stream`.

- **Chat layout and view** — A dark-themed admin chat interface shipped in the gem (not generated). Includes sidebar with session list, message history, SSE streaming, and keyboard navigation.

- **`Ask::Rails::Auth`** — Configurable authentication hook. Set `Ask::Rails::Auth.check = -> { ... }` to protect the chat behind your existing auth system. Runs in controller context — `current_user`, `redirect_to`, etc. are available.

- **Engine routes** — Routes defined in `config/routes.rb` with proper `Ask::Rails::Engine.routes.draw` isolation.

### Changed

- **README** — Rewritten with clear positioning: ask-rails is for internal admin agents. ask-agent is for external-facing agents. Includes comparison table, quick start guide, and tool reference.
- **Engine** — `isolate_namespace Ask::Rails` for proper route isolation.
- **Gemspec** — Now includes `app/` and `config/` directories for engine views, controllers, and routes.

## [0.2.5] - 2026-06-25

### Changed
- Expanded tests: Persistence(7t), Configuration(7t), ServiceDiscovery(5t), Engine(7t), InstallGenerator(7t), Tools(24t with live DB). Infrastructure: rubocop, overcommit, CI matrix, Appraisals, gemspec.
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
