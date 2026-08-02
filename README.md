# ask-rails

[![Gem Version](https://badge.fury.io/rb/ask-rails.svg)](https://badge.fury.io/rb/ask-rails)

Rails integration for the [ask-rb](https://github.com/ask-rb) ecosystem. Provides generators, file conventions, and a railtie for building user-facing AI features (agents, workflows, actions) inside a Rails app. Requires Rails 7.1+.

## Installation

Add to your Gemfile:

```ruby
gem "ask-rails"
gem "ask-graph"   # optional, add only if you use workflows
```

Run the installer:

```bash
bundle install
rails generate ask:install
```

This creates:

| File | Purpose |
|---|---|
| `config/initializers/ask.rb` | Agent, workflow, and action configuration |
| `app/agents/application_agent.rb` | Base class for your agents |
| `app/actions/application_action.rb` | Base class for your actions |
| `app/workflows/application_workflow.rb` | Base class for your workflows (only with ask-graph) |
| `db/migrate/*_create_ask_state.rb` | Shared key-value state table |
| `db/migrate/*_create_ask_audit_logs.rb` | Agent session audit log |

No controllers, views, or routes are generated. The admin chat UI ships in [ask-rails-harness](https://github.com/ask-rb/ask-rails-harness).

## Generators

- `rails generate ask:agent NAME`: creates `app/agents/<name>/` with `agent.rb`, `instructions.md`, and `tools/`.
- `rails generate ask:action NAME [NAMESPACE]`: creates an action under `app/actions/` (e.g. `ask:action chats create` → `app/actions/chats/create.rb`).
- `rails generate ask:workflow NAME`: creates `app/workflows/<name>/workflow.rb` and `steps/` (requires ask-graph).
- `rails generate ask:install --skip-graph`: skips workflow scaffolding when you don't use ask-graph.

## Quick Start

```ruby
# app/agents/support_bot/agent.rb
module SupportBot
  class Agent < ApplicationAgent
    model "gpt-4o"
  end
end
```

```ruby
agent = Ask::Agent.new("support_bot")
response = agent.run("How do I reset my password?")
puts response
```

The directory name is the agent name. `instructions.md` next to `agent.rb` is auto-loaded as the system prompt.

## Essential API

### Ask::Actions: dispatch operations by name from any channel

```ruby
context = Ask::Actions::Context.new(user: current_user, session: session)
result = Ask::Actions.dispatch(action: "chats.create", context: context, params: { name: "general" })
result.ok?       # => true
result.message   # => "Chat created"
```

`"chats.create"` resolves to `Chats::Create` (Zeitwerk autoloads `app/actions/`). Register explicitly to override the convention or list actions:

```ruby
Ask::Actions.register "chats.create", Chats::Create
Ask::Actions.available   # => ["chats.create"]
```

Actions return an `Ask::Actions::Result` (`Result.ok` / `Result.error`). Unknown action names raise `Ask::Actions::Backend::UnknownAction`.

### Ask::Rails::State: ActiveRecord-backed state

`Ask::Rails::State` backs the `ask_state` table and works with any database (PostgreSQL, MySQL, SQLite). ask-graph stores workflow checkpoints there; ask-agent session persistence uses the same table, keyed by convention.

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs. [Rails app integration](https://ask-rb.github.io/ask-docs/getting-started/rails-app) covers ask-rails in depth. API reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

```bash
bundle install
bundle exec rake test
```

## License

MIT
