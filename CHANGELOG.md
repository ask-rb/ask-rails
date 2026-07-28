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
