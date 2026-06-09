# ask-rails — Rails Integration

## Purpose

The only gem a Rails app needs to join the ask-rb ecosystem. Provides:
- **Railtie** (not Engine — no routes, no UI, no views to mount)
- **AR session persistence** — save/load agent sessions to the database
- **Session factory** — `Ask::Rails.agent_session` creates a pre-configured agent
- **Service gem discovery** — auto-discovers installed `ask-*` gems, reads their context modules, injects them into the system prompt
- **Generators** — `rails generate ask_rails:install`
- **Configuration** — `config.ask_rails.default_model`, `max_turns`, etc.

Transformed from `solid_agents` at `github.com/ask-rb/solid_agents`. Strip the workflow engine, UI, jobs, schedules, error subscriber. Keep and polish the Railtie, generators, persistence, configuration patterns.

## Dependencies

- **Runtime:**
  - `rails >= 7.1` (core dependency — this is a Rails integration gem)
  - `ask-tools` (for `Ask::Tool` base class, tool discovery)
  - `ask-tools-shell` (for execution tools)
  - `ask-agent` (for `Ask::Agent::Session`)
  - `ask-auth` (for credential resolution config)
  - `ruby_llm` (**temporary** — until provider gems replace it)
- **Build/test:** minitest, mocha, rake, sqlite3 (for test dummy app)
- **This gem MUST wait until `ask-agent`, `ask-tools`, `ask-tools-shell`, and `ask-auth` are all built, tested, and released.**

## Implementation Steps

### 1. Define the gem scaffold
- `lib/ask-rails.rb` — entry point
- `lib/ask/rails.rb` — main module with `configure`, configuration accessors
- `lib/ask/rails/railtie.rb` — Railtie class (not Engine)
- `lib/ask/rails/version.rb`
- `lib/ask/rails/persistence.rb` — ActiveRecord session persistence (lifted from conductor)
- `lib/ask/rails/configuration.rb` — default configuration, blank normalization
- `lib/ask/rails/session_factory.rb` — `Ask::Rails.agent_session`
- `lib/ask/rails/service_discovery.rb` — auto-discovers installed `ask-*` gems
- `lib/ask/rails/tool.rb` — `Ask::Rails::Tool < Ask::Tool` base for Rails-specific tools
- `lib/generators/ask/rails/install/install_generator.rb`
- `app/views/layouts/` — not needed (no Engine, no UI)
- Write `ask-rails.gemspec`

### 2. Build Railtie (`lib/ask/rails/railtie.rb`)
- Inherit from `Rails::Railtie` (not `Engine`)
- `rake_tasks` block to load rake tasks
- `generators` block — load install generator
- `initializer "ask_rails.configure_llm"` — configure RubyLLM from app config (env vars)
- `initializer "ask_rails.discover_tools", after: :eager_load_most` — discover tools in `app/tools/`
- `initializer "ask_rails.discover_services", after: :eager_load_most` — discover `ask-*` service gems

### 3. Build configuration (`lib/ask/rails/configuration.rb`)
- `mattr_accessor` style config on the `Ask::Rails` module
- Options: `default_model`, `max_turns`, `system_prompt`, `tool_concurrency`, `persistence_adapter`
- Blank normalization: empty strings → `nil` (adopted from ruby_llm 1.16)

### 4. Build service discovery (`lib/ask/rails/service_discovery.rb`)
- On boot, scan `Gem.loaded_specs` for gems matching `ask-*` (excluding `ask-tools`, `ask-agent`, `ask-rails`, `ask-auth`)
- For each, `require "#{name.tr('-', '/')}/context"` and read the context module
- Build a system prompt section from all discovered service contexts:
  - `DESCRIPTION`, `QUICK_START`, `DOCS_URL`, `AUTH_HOW` from each service
  - `Error::MAP` from each service's error guide
- Inject the generated prompt into the session's system prompt

### 5. Build session factory (`lib/ask/rails/session_factory.rb`)
- `Ask::Rails.agent_session` creates an `Ask::Agent::Session` pre-configured with:
  - Default model from config
  - Tools from `Ask::Tools::Shell.all`
  - Auto-generated system prompt from discovered services
  - AR persistence if configured
  - Rails executor wrapping for background job safety

### 6. Build Rails-specific tools
- `Ask::Rails::Tool < Ask::Tool` — base class with `Rails.root` access
- `Ask::Rails::ReadFile` — reads files, `Rails.root`-relative paths
- `Ask::Rails::RunCommand` — runs commands in `Rails.root` context
- `Ask::Rails::SearchCodebase` — greps the Rails app directory
- `Ask::Rails::ReadRoute` — reads `config/routes.rb`
- These are convenience wrappers that save the agent from writing `Rails.root.join(...)` every time

### 7. Build generators (`lib/generators/ask/rails/install/`)
- `rails generate ask_rails:install`:
  - Creates migration for session persistence table
  - Creates initializer with default configuration
  - Creates `app/tools/` directory for app-specific tools
- Migration template creates `ask_sessions` table with:
  - `id`, `session_id` (UUID), `model`, `messages` (jsonb/text), `metadata` (jsonb)
  - `created_at`, `updated_at`

### 8. Port AR persistence from conductor
- Move `conductor/persistence/active_record.rb` to `ask/rails/persistence.rb`
- Adapt to work with `Ask::Agent::Session` rather than `RubyLLM::Conductor::Session`
- The persistence adapter saves/loads session messages, metadata, model info

### 9. Test coverage
- Test Railtie initializers fire in correct order
- Test service discovery finds installed `ask-*` gems and reads their context
- Test session factory creates a configured agent session
- Test AR persistence saves and loads session state
- Test generators produce correct migration and initializer
- Test blank configuration normalization
- Test system prompt generation includes all discovered services with correct formatting
- Test Rails tool wrappers work

### 10. README
- Installation (add to Gemfile + generate)
- Quick start: `Ask::Rails.agent_session.run("message")`
- Configuration reference (all options with defaults)
- Adding Rails-specific tools in `app/tools/`
- How service gems are discovered and injected into system prompt
- Persistence and background jobs
- Migration guide from `solid_agents`

### 11. Production hardening
- Railtie initializers should handle missing tables gracefully (don't crash on fresh `db:create`)
- AR persistence should handle concurrent session saves
- Service discovery should handle missing context modules gracefully
- Session factory should work in both web requests and background jobs
- Configuration validation: empty model names → nil, invalid max_turns → clamp

## What "Done" Means

- Railtie loads in Rails app without errors
- `Ask::Rails.agent_session` creates a working agent with all configured tools
- Service discovery reads installed `ask-*` gems and generates a system prompt
- AR persistence saves and loads agent sessions
- `rails generate ask_rails:install` works and produces correct files
- Blank config values normalize to `nil`
- Rails tools (`ReadFile`, `RunCommand`, `SearchCodebase`, `ReadRoute`) work
- >90% test coverage with a Rails dummy app
- README full documentation
- Works in both web requests and ActiveJob background jobs

## Documentation

### Documentation
- **Update ask-docs** after releasing v0.1.0 — the docs site at github.com/ask-rb/ask-docs must reflect this gems API, usage, and position in the ecosystem.
- The ask-docs repo has a Jekyll site with sections for each gem under core/, providers/, tools/, agent/.
- Add or update the relevant page(s) and submit a PR to ask-docs.
- This is not optional — ask-docs is the public face of the ecosystem.

## Improving Parent Gems During Development

### Improving Parent Gems During Development

If during development you discover something in a parent gem (a dependency of this gem)
that needs to be fixed or improved:

1. Make the change in the parent gem's repository at `/Users/kaka/Code/ask-rb/GEMNAME/`
2. Ensure existing tests in the parent gem still pass: `cd ../PARENT && bundle exec rake test`
3. Ensure tests in THIS gem still pass: `bundle exec rake test`
4. Ensure the parent gem still builds: `gem build *.gemspec`
5. Commit the parent gem change, bump its patch version, and push:
   `cd ../PARENT && git commit -m "fix: ..." && git push`
6. Update this gem's Gemfile to reference the updated parent gem
7. Continue with this gem's implementation using the fixed parent

Do NOT break parent functionality. Do NOT change parent APIs without testing
both gems. Parent gems have their own consumers — treat them with care.

## Release Checklist (Required for v0.1.0)

Before declaring this gem done and releasing v0.1.0, verify:

- [] All tests pass with >90% coverage
- [] Every public API method has documentation (yardoc or inline comments)
- [] README is complete: installation, quick start, configuration, development
- [] CHANGELOG.md exists with an entry for v0.1.0
- [] All code is committed and pushed to github.com/ask-rb/ask-rails
- [] Gem builds without errors: gem build *.gemspec
- [] Gem is released on RubyGems
- [] A consumer app can install, require, and use the gem with no errors
- [] Thread-safety verified (registry, config, client construction)
- [] Error messages are helpful and actionable

## What Done Means for v0.1.0

The gem reaches v0.1.0 when:
- All implementation steps above are complete and tested
- The gem is released on RubyGems
- A real consumer can install it with gem install or Bundler
- A consumer script can require it and use its full public API
- The README provides enough information for someone unfamiliar to get started in 5 minutes
- The CHANGELOG documents what v0.1.0 delivers

## Development Workflow

### Git conventions
- The default branch is **master**. All work should be based on master unless a specific branch is requested.

- Follow the git-workflow skill for branch naming, commit messages, and PR structure.
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- One logical change per commit. No "fixup" or "wip" commits on master.
- Commit messages must be one direct sentence describing the change.

### Reference projects
Study existing implementations for patterns and conventions:

- **ask-tools-shell** — extract from `ruby_llm-conductor/lib/ruby_llm/conductor/tools/`
- **ask-agent** — port from `ruby_llm-conductor/` (session, loop, tool_executor, compactor, etc.)
- **ask-rails** — transform from `solid_agents/` (railtie, generators, persistence)
- **ask-openai, ask-anthropic** — study `ruby_llm/lib/ruby_llm/providers/` for wire formats and streaming patterns
- **ask-openai** — also study `llm-proxy/lib/llm_proxy/protocols/` for OpenAI protocol conversion
- **General patterns** — study `pi/packages/ai/src/providers/` for lazy loading, registration, and protocol families
- **Test patterns** — study `ruby_llm/spec/` for VCR cassette structure and integration testing patterns
- **ask-github** — reference implementation for service context gems; follow its three-file pattern
### Reference Repositories (Local)
All ask-rb gem repos are available locally at /Users/kaka/Code/ask-rb/ for reference.
Do not clone from GitHub — use the local directories:
- Source code: /Users/kaka/Code/ask-rb/GEMNAME/lib/
- Tests: /Users/kaka/Code/ask-rb/GEMNAME/test/
- Goal: /Users/kaka/Code/ask-rb/GEMNAME/GOAL.md
- Gemspec: /Users/kaka/Code/ask-rb/GEMNAME/GEMNAME.gemspec

Other reference projects in the same workspace:
- /Users/kaka/Code/ask-rb/ruby_llm/ — RubyLLM gem (providers, models, streaming)
- /Users/kaka/Code/ask-rb/ruby_llm-conductor/ — Original conductor (agent loop, tools)
- /Users/kaka/Code/ask-rb/llm-proxy/ — Protocol normalization patterns
- /Users/kaka/Code/ask-rb/pi/ — Pi agent (TypeScript, provider architecture)
- /Users/kaka/Code/ask-rb/solid_agents/ — Original solid_agents (Rails engine)
- /Users/kaka/Code/ask-rb/composio/ — Composio SDK (MCP tool execution examples)
- /Users/kaka/Code/ask-rb/ask-docs/ — Documentation site (update after release)

### Testing
- Use Minitest (not RSpec) — consistent with the ask-rb ecosystem.
- Unit tests for every public method (normal path + edge cases + error cases).
- Integration tests with VCR cassettes for any gem that calls external APIs.
- Run the full suite before every commit: `bundle exec rake test`.
