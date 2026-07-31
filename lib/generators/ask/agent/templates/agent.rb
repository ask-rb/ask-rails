# frozen_string_literal: true

# <%= class_name %> agent.
#
# Run it:
#   agent = Ask::Agent.new("<%= file_name %>")
#   response = agent.run("Hello")
#
# Instructions load automatically from instructions.md next to this file.
# Per-agent tools live in tools/ — reference them with `tools :tool_name`.
#
module <%= class_name %>
  class Agent < ApplicationAgent
    # model "gpt-4o"
    # provider :openai
    # max_turns 25

    # tools :bash
    # tools :read
    # tools :grep
  end
end
