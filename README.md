# ask-rails

Rails integration for the [ask-rb](https://github.com/ask-rb) ecosystem. Provides generators, file conventions, and railtie for using AI agents in your Rails app.

## Installation

```bash
bundle add ask-rails
rails generate ask:install
```

This creates:
- `config/initializers/ask.rb` — agent configuration
- `app/agents/application_agent.rb` — base class for your agents
- `app/agents/` — directory for agent definitions

## Usage

Define an agent:

```ruby
# app/agents/support_bot.rb
class Agents::SupportBot < ApplicationAgent
  model "gpt-4o"
  system_prompt "You help users with support questions."

  tool :bash
  tool :read
  tool :grep
end
```

Run it:

```ruby
agent = Ask::Agent.new("support_bot")
response = agent.run("Find all open issues in the codebase")
puts response
```

Or use `Ask.chat` for one-off conversations:

```ruby
Ask.chat("Summarize this article: #{text}")
```

## Configuration

API keys are resolved automatically by `Ask::Auth`:

- **Environment variables:** `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, etc.
- **Rails credentials:** `rails credentials:edit` → add `ask.openai`, `ask.anthropic`
- **File:** `~/.ask/credentials.yml`

No manual credential setup is required.

## License

MIT
