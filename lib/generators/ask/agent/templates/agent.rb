# frozen_string_literal: true

# <%= class_name %> agent.
#
# Run it:
#   agent = Ask::Agent.new("<%= file_name %>")
#   response = agent.run("Hello")
#
module Agents
  class <%= class_name %> < ApplicationAgent
    # model "gpt-4o"
    system_prompt "You are a helpful assistant."

    # tool :bash
    # tool :read
    # tool :grep
  end
end
