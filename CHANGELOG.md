## [0.9.0] — 2026-07-30

### Fixed

- **Agent generator + templates now follow the ask-agent directory convention.**
  `rails generate ask:agent support_bot` creates `app/agents/support_bot/agent.rb`
  + `instructions.md` + `tools/` (the discovery layout), not a flat
  `app/agents/support_bot.rb`. Templates no longer reference the removed
  `system_prompt`/`tool` Definition DSL — they use `model`, `provider`,
  `max_turns`, and `tools` (plural), with instructions auto-loaded from
  the sibling `instructions.md`.

## [0.8.0] — 2026-07-31

### Added

- **`Ask::Actions` — action convention** — user-facing operations callable from any channel (web, Slack, voice) by name:

  ```ruby
  Ask::Actions.dispatch(action: "chats.create", context: context, params: {})
  ```

  - `Ask::Actions::Result` — uniform response shape (`ok`/`error`, `message`, `data`, `code`)
  - `Ask::Actions::Context` — per-request context bag; attributes become accessors
  - `Ask::Actions::Backend` — dispatcher with explicit registration (`Ask::Actions.register`) and convention resolution (`"chats.create"` → `Chats::Create` via Zeitwerk). Unknown actions raise `Ask::Actions::Backend::UnknownAction` with guidance.

- **`ask:action NAME [NAMESPACE]` generator** — scaffolds actions:

  ```bash
  rails generate ask:action create_workspace   # app/actions/create_workspace.rb
  rails generate ask:action chats create       # app/actions/chats/create.rb → "chats.create"
  ```

- **Actions in install generator** — `ask:install` now creates `app/actions/` and `app/actions/application_action.rb` (base class with `call(context:, params:)` → `#call`). The initializer documents the actions block with a registration example.

### Tested

- 25 new tests (Result, Context, Backend, generators) — 48 runs, 141 assertions, 0 failures.
- End-to-end smoke test in a fresh Rails 8.1 app: `ask:install` + `ask:action` (namespaced and top-level) run; `Ask::Actions.dispatch` resolves both via convention; unknown actions raise with a helpful message.

## [0.7.0] — 2026-07-31

### Added

- **`ask:agent NAME` generator** — scaffolds an individual agent under `app/agents/`:

  ```bash
  rails generate ask:agent support_bot
  ```

- **`ask:workflow NAME` generator** — scaffolds a workflow module under `app/workflows/<name>/` with `workflow.rb` and `steps/` directory. Requires ask-graph; aborts with a helpful message if it's not installed:

  ```bash
  rails generate ask:workflow notify_customer
  ```

- **`Ask::Rails::State`** — ActiveRecord-backed state adapter for the `ask_state` table. Used by ask-graph for workflow checkpoints. Works with any database adapter (PostgreSQL, MySQL, SQLite). Implements key-value storage plus ordered lists (for agent session indexes).

- **ask-graph support in install generator** — `ask:install` now creates `app/workflows/application_workflow.rb` and the workflows directory when ask-graph is installed. Pass `--skip-graph` to skip. The initializer's graph block is only generated when ask-graph is present:

  ```ruby
  if defined?(Ask::Graph)
    Ask::Graph.storage = Ask::Rails::State.new
  end
  ```

### Changed

- **Generators consolidated under `lib/generators/ask/`** — all three generators (`ask:install`, `ask:agent`, `ask:workflow`) now live at the standard Rails discovery path. The old railtie-registered `ask:rails:*` names and the duplicate `lib/generators/ask/install_generator.rb` were removed. No duplicated work between generators: `ask:install` owns one-time setup, `ask:agent`/`ask:workflow` own per-component scaffolding.

- **Initializer fixed to use real APIs** — removed references to non-existent `Ask::State::PostgreSQL` and `config.state`. The agent block now only configures what ask-agent supports (audit log, default model).

- **State migration uses `t.json` instead of `t.jsonb`** — works on PostgreSQL, MySQL, and SQLite.

- **`migration_version` fix** — generated migrations now produce `ActiveRecord::Migration[8.1]` instead of the broken `Migration[[8.1]]`.

### Tested

- 24 tests, 67 assertions, 0 failures — including 13 tests for `Ask::Rails::State` against an in-memory SQLite database.
- End-to-end smoke test in a fresh Rails app: `ask:install`, `ask:agent`, `ask:workflow` all run; migrations execute; a workflow checkpoint survives a second run via `Ask::Rails::State`.

## [0.6.0] — 2026-07-29

### Added

- **`ask_state` migration in install generator** — `rails generate ask:install` now creates `db/migrate/create_ask_state.rb` with a shared key-value table for agent sessions and graph checkpoints.

- **Standard Rails generator path** — Generator moved to `lib/generators/ask/install_generator.rb` for automatic Rails discovery. Run `rails generate ask:install` with no additional configuration.

### Changed

- Generator creates two migrations with unique timestamps: `ask_state` first, then `ask_audit_logs`.

### Tested

- `rails generate ask:install` tested in production Rails app (kawibot) — creates initializer and both migrations.
- Migrations run successfully against PostgreSQL.

## [0.5.0] — 2026-07-26

### Added

- **Audit log migration in install generator** — `rails generate ask_rails:install` now creates `db/migrate/create_ask_audit_logs.rb` with `if_not_exists: true`.
  Table schema: `session_id`, `event_type`, `jsonb data`, `timestamp`, `created_at`, `updated_at`. Indexed on `[session_id, event_type]` and `timestamp`.

### Changed

- Install generator now includes `::Rails::Generators::Migration` for `migration_template` support.

## [0.4.0] — 2026-07-26

### Added

- **ask-rails-harness** — new `Ask::Rails::Harness` module for configuring the Rails-facing agent harness. Separates ask-rb ecosystem configuration from Rails-specific agent harness settings.

### Changed

- `config/initializers/ask_rails.rb` now configures `Ask::Rails::Harness` instead of `Ask::Rails`.

## [0.1.0] — 2026-07-26

### Added

- Initial release of `ask-rails` — Rails integration for the ask-rb ecosystem.
- **Install generator** — `rails generate ask:install` creates `config/initializers/ask.rb`, `app/agents/application_agent.rb`, and `app/agents/` directory.
- **Railtie** — Wires `Ask::Agent.logger` to `Rails.logger`, discovers agent definitions in `app/agents/`.
