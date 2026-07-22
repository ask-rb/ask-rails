## [0.8.0] — 2026-07-23

### Added

- **SchemaGraph tool** — Full application schema introspection in one call. Returns every model, table, column (with types and nullability), association (belongs_to, has_many, has_one, HABTM, through), validation, index, and polymorphic relationship. The agent gets a complete mental model of the app's data layer — no more reading models one at a time.
  - `schema_graph(detail: "all")` — everything
  - `schema_graph(detail: "models")` — just models and columns
  - `schema_graph(detail: "associations")` — just the association graph
  - `schema_graph(detail: "tables")` — just tables, columns, and indexes

- **RouteInspector tool** — Parsed Rails route table (not raw routes.rb). Returns every route with HTTP verb, path, controller, action, and name. Supports filtering by controller and path pattern. Replaces the old ReadRoutes which returned raw file content.
  - `route_inspector` — all routes
  - `route_inspector(controller: "users")` — routes for a specific controller
  - `route_inspector(pattern: "admin")` — routes matching a path pattern

- **Core tools auto-discovery** — The 9 built-in Rails tools (ReadFile, RunCommand, SearchCodebase, ReadRoutes, QueryDatabase, ReadModel, ReadLog, SchemaGraph, RouteInspector) are now automatically included in every agent session. Previously they were loaded but not registered.

### Changed

- `discover_tools!` now includes `CORE_RAILS_TOOLS` — all 9 Rails tools are automatically available to the agent.

## [0.7.0] — 2026-07-23

### Added

- **Tool execution visualization** — The chat UI now shows live tool execution cards as the agent runs. Each tool call displays as an expandable card with name, args, and real-time elapsed time. Cards show ✓ for success or ✗ for failure with duration.
- **Activity panel** — New "Activity" sidebar tab shows the audit log in real-time. Browse recent tool calls across all sessions with status, duration, and timestamp.
- **Per-session audit view** — Clicking a session loads its audit trail. New `GET /ask/sessions/:session_id/audit` endpoint.
- **Individual session deletion** — Delete sessions one at a time via the ✕ button in the sidebar. New `DELETE /ask/sessions/:id` route.
- **Sidebar search** — Filter sessions by text in the sidebar search box.
- **Session previews** — Sidebar shows the first message as a preview instead of just the session ID.
- **Keyboard shortcuts** — Ctrl+K / Cmd+K focuses the input. Enter sends (Shift+Enter for newline).
- **Environment badge** — Current Rails.env shown in both the sidebar footer and chat header.
- **`destroy_session` action** — New controller action for deleting individual sessions.

### Changed

- **Chat layout** — Complete visual overhaul: darker theme, improved spacing, tool cards, sidebar tabs (Sessions/Activity), session search, and streaming indicator.
- **`message` SSE stream** — Now emits `tool_start`, `tool_end`, and `tool_update` events alongside `delta` and `thinking` for real-time tool execution visibility.
- **Controller actions** — `destroy` renamed to `destroy_all` for clarity.

## [0.6.0] — 2026-07-23

### Added

- **Per-environment permissions** — Configure access modes and command allowlists per Rails environment:
  ```ruby
  Ask::Rails.configure do |config|
    config.environment :production do |env|
      env.mode = :read_only
      env.allowed_commands = [/^rails routes/]
      env.denied_commands = [/rm/, /dropdb/]
    end

    config.environment :development do |env|
      env.mode = :full_access
    end
  end
  ```
- **`Ask::Rails::EnvironmentPermissions`** — New config class holding `mode`, `allowed_commands`, and `denied_commands` per environment.
- **Automatic Permissions wiring** — When an environment `mode` is set, `agent_session` automatically creates an `Ask::Agent::Extensions::Permissions` extension and wires it into the session hooks.
- **Effective rule resolution** — `Configuration#effective_allowed_commands`, `#effective_denied_commands`, and `#effective_mode` resolve per-environment rules or fall back to global config.

## [0.5.0] — 2026-07-22

### Added

- **Command Allowlist** — `RunCommand` now checks `allowed_commands` and `denied_commands` before executing. Configure with regex patterns:
  - `Ask::Rails.configuration.allowed_commands = [/^rails /, /^git status/]`
  - `Ask::Rails.configuration.denied_commands = [/rm /, /dropdb/]`
  - `denied_commands` takes precedence over `allowed_commands`
  - When `allowed_commands` is nil (default), all commands pass through (except those in `denied_commands`)
  - Blocked commands return `Ask::Result.error` with a descriptive message and are recorded in the audit log

- **`allowed_commands` and `denied_commands` configuration options** — Two new arrays of regex patterns on the `Configuration` object.

## [0.4.0] — 2026-07-22

### Added

- **Audit Log** — Every tool call is now recorded in the `ask_audit_logs` table with the intent (sanitized params), outcome (status/timing), and user context. Append-only, never modified. Provides a trustworthy record of what the agent did without storing sensitive data or full results.
  - `Ask::Rails::AuditLog.log` — logs a tool execution event
  - Sensitive params (keys matching `password`, `secret`, `token`, `api_key`, `key`) are automatically redacted as `[REDACTED]`
  - Fires `audit_log.ask_rails` ActiveSupport notification for host app alerting
  - Results are summarized (row count for queries, exit status for commands, etc.) — full data never stored
  - Generator creates the `create_ask_audit_logs` migration

- **`current_user` configuration** — `Ask::Rails.configure { |c| c.current_user = -> { Current.user ? { id: Current.user.id, email: Current.user.email } : nil } }` attaches user context to every audit log entry.

- **`Ask::Rails::Tool.session_id`** — Thread-local accessor so tool calls are correlated with their agent session in the audit log.

### Changed

- **Tool base class** — `Ask::Rails::Tool#call` is now instrumented to automatically log every invocation to the audit log. All 7 Rails tools inherit this behavior.

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
