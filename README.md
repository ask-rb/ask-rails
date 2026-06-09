# ask-rails

Rails integration for the ask-rb ecosystem. The only gem a Rails app needs to join
the ask-rb stack — provides a Railtie, AR session persistence, a session factory,
automatic service gem discovery, and generators.

## Installation

```bash
bundle add ask-rails
rails generate ask_rails:install
```

## Usage

```ruby
# In any Rails context
session = Ask::Rails.agent_session
session.run("Find all open issues labeled 'bug' in our repo")
```

Service gems like `ask-github`, `ask-slack` are auto-discovered — the agent gets their
context (auth info, quick-start snippets, error guides) in the system prompt automatically.

## Development

```bash
bin/setup
bundle exec rake test
```

## License

MIT
