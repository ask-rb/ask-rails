# ask-rails

An admin AI agent for your Rails app. Mount the engine, get a chat interface at `/ask` that can inspect your code, query your database, read logs, and help you debug — all through an authenticated admin UI.

## Who is this for?

- **Rails developers** who want an AI co-pilot that understands their app's codebase, schema, routes, and logs
- **Internal/Admin use only** — the agent has direct access to your database, file system, and shell. Not for external/customer-facing use.

For building customer-facing AI agents, use `ask-agent` directly with your own tools and UI.

## What it gives you

- **7 Rails-aware tools**: `ReadFile`, `QueryDatabase`, `ReadRoutes`, `ReadModel`, `ReadLog`, `RunCommand`, `SearchCodebase`
- **Admin chat UI**: Mount the engine, get a working chat at `/ask` with SSE streaming
- **Auth integration**: Protect `/ask` behind your existing Devise/authentication
- **AR persistence**: Agent sessions survive server restarts
- **Service discovery**: Auto-detects installed ask-* service gems
- **Skills**: Built-in guides for Rails debugging, deployment, and database performance

## Installation

```bash
bundle add ask-rails
rails generate ask_rails:install
```

## Quick Start

Add the engine mount and auth protection to `config/routes.rb`:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ... your routes ...

  authenticate :user, ->(u) { u.admin? } do
    mount Ask::Rails::Engine, at: "/ask"
  end
end
```

Then visit `/ask` in your browser.

## Usage

### Configuration

```ruby
# config/initializers/ask_rails.rb
Ask::Rails.configure do |c|
  c.default_model = "claude-sonnet-4"
  c.max_turns = 50
end
```

### Programmatic Access

```ruby
# From any controller, view, or job
session = Ask::Rails.agent_session
session.run("Find all open issues labeled 'bug' in our repo")
```

### Route Helpers

```ruby
ask_rails.root_path               # => /ask
ask_rails.sessions_path           # => /ask/sessions
ask_rails.session_messages_path(session_id) # => /ask/sessions/:id/messages
```

### Auth

By default, the admin chat is unprotected. Add auth in your routes (as shown above) or set a custom check:

```ruby
# config/initializers/ask_rails.rb
Ask::Rails::Auth.check = -> {
  redirect_to main_app.login_path unless current_user&.admin?
}
```

## Tools

| Tool | What it does |
|---|---|
| `ReadFile` | Read any file (relative to `Rails.root`) |
| `QueryDatabase` | Run read-only SQL (rejects non-SELECT in production) |
| `ReadModel` | Inspect AR model schema, associations, validations |
| `ReadRoutes` | View `config/routes.rb` |
| `ReadLog` | Read log files with level/search filtering |
| `RunCommand` | Run shell commands in the app root |
| `SearchCodebase` | Grep the codebase for patterns |

## Engine Routes

```
GET  /ask                    → Chat UI
POST /ask/sessions           → Create new session
POST /ask/sessions/:id/messages → Send message (SSE streamed response)
GET  /ask/sessions/:id/messages → Get message history
GET  /ask/sessions/:id/stream  → SSE stream for existing session
```

## Compared to ask-agent

| `ask-agent` | `ask-rails` |
|---|---|
| Build external-facing agents | Build an internal admin co-pilot |
| Bring your own tools | Ships Rails-specific tools |
| Bring your own UI | Ships an admin chat UI |
| Any Ruby app | Rails apps only |
| General purpose | Development, debugging, ops |

## License

MIT
