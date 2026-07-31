# ask-rails

Rails integration for the [ask-rb](https://github.com/ask-rb) ecosystem. Provides generators, file conventions, and a railtie for building agents and workflows in your Rails app.

## Installation

Add to your Gemfile:

```ruby
gem "ask-rails"
gem "ask-graph"   # optional — add only if you use workflows
```

Run the installer:

```bash
bundle install
rails generate ask:install
```

This creates:

| File | Purpose |
|---|---|
| `config/initializers/ask.rb` | Agent + workflow configuration (graph block only generated when ask-graph is installed) |
| `app/agents/application_agent.rb` | Base class for your agents |
| `app/actions/application_action.rb` | Base class for your actions |
| `app/workflows/application_workflow.rb` | Base class for your workflows (only with ask-graph) |
| `db/migrate/*_create_ask_state.rb` | Shared key-value state table — workflow checkpoints and agent session indexes |
| `db/migrate/*_create_ask_audit_logs.rb` | Agent session audit log |

The `ask_state` table is backed by `Ask::Rails::State` — an ActiveRecord adapter that works with any database (PostgreSQL, MySQL, SQLite). Workflow checkpoints and agent session persistence share the same table, keyed by convention.

## Generators

### `ask:agent NAME`

Scaffolds a new agent:

```bash
rails generate ask:agent support_bot
```

Creates the agent directory convention used by ask-agent discovery:

```
app/agents/support_bot/
├── agent.rb           # class Agents::SupportBot < ApplicationAgent
├── instructions.md    # auto-loaded as the system prompt
└── tools/             # per-agent tools (referenced with `tools :tool_name`)
```

```ruby
# app/agents/support_bot/agent.rb
module Agents
  class SupportBot < ApplicationAgent
    model "gpt-4o"
    # tools :search_knowledge_base
  end
end
```

Run it with `Ask::Agent.new("support_bot")`. The directory name is the
agent name — keep the file named `agent.rb`.

### `ask:workflow NAME`

Scaffolds a new workflow (requires ask-graph):

```bash
rails generate ask:workflow notify_customer
```

Creates `app/workflows/notify_customer/workflow.rb` and `app/workflows/notify_customer/steps/`:

```ruby
module NotifyCustomer
  class Workflow < ApplicationWorkflow
    # step SomeStep
  end
end
```

### `ask:action NAME [NAMESPACE]`

Scaffolds a new action — a user-facing operation callable from any channel (web, Slack, voice) by name:

```bash
rails generate ask:action create_workspace   # app/actions/create_workspace.rb
rails generate ask:action chats create       # app/actions/chats/create.rb
```

Creates `app/actions/chats/create.rb`:

```ruby
module Chats
  class Create < ApplicationAction
    def call
      Ask::Actions::Result.ok(message: "Chat created", data: { id: record.id })
    end
  end
end
```

### Skipping workflow scaffolding

If you don't use ask-graph, install with:

```bash
rails generate ask:install --skip-graph
```

The initializer still works — the graph block is omitted when ask-graph isn't installed.

## Usage

### Agents

```ruby
# app/agents/support_bot.rb
module Agents
  class SupportBot < ApplicationAgent
    model "gpt-4o"
    system_prompt "You help users with support questions."

    tool :bash
    tool :read
  end
end
```

```ruby
agent = Ask::Agent.new("support_bot")
response = agent.run("Find all open issues in the codebase")
puts response
```

### Workflows

```ruby
# app/workflows/order_fulfillment/workflow.rb
module OrderFulfillment
  class Workflow < ApplicationWorkflow
    step ValidatePayment
    step NotifyCustomer
    step ShipOrder
  end
end
```

```ruby
# app/workflows/order_fulfillment/steps/validate_payment.rb
module OrderFulfillment
  class ValidatePayment
    def call(context)
      context.payment = PaymentService.charge(context.input[:order])
    end
  end
end
```

```ruby
result = OrderFulfillment::Workflow.call(order: order)
result.payment
```

Checkpoints are saved to the shared `ask_state` table, so workflows resume after crashes.

### Actions

Actions are the operations your users trigger — booking an appointment, creating a chat, upgrading a plan. They live in `app/actions/` and are dispatched **by name**, so any channel (web controller, Slack handler, voice agent) calls the same operation:

```ruby
# app/actions/chats/create.rb
module Chats
  class Create < ApplicationAction
    def call
      chat = context.channel.start_new_chat!
      Ask::Actions::Result.ok(message: "Chat created", data: { chat: chat })
    end
  end
end
```

```ruby
# From any channel:
context = Ask::Actions::Context.new(user: current_user, session: session)
result = Ask::Actions.dispatch(action: "chats.create", context: context, params: { name: "general" })
result.ok?      # => true
result.message  # => "Chat created"
result.data     # => { chat: ... }
```

By convention, `"chats.create"` resolves to `Chats::Create` — no registration needed (Zeitwerk autoloads `app/actions/`). Register explicitly to override the convention or to list actions in `Ask::Actions.available`:

```ruby
# config/initializers/ask.rb
Ask::Actions.register "chats.create", Chats::Create
```

Unknown action names raise `Ask::Actions::Backend::UnknownAction` with a helpful message.

## Configuration

API keys are resolved automatically by `Ask::Auth`:

- **Environment variables:** `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, etc.
- **Rails credentials:** `rails credentials:edit` → add `ask.openai`, `ask.anthropic`
- **File:** `~/.ask/credentials.yml`

No manual credential setup is required.

## License

MIT
