# frozen_string_literal: true

# Base class for your application's AI agents.
#
# Subclass this to define agents:
#
#   class Agents::SupportBot < ApplicationAgent
#     model "gpt-4o"
#     system_prompt "You help users with support questions."
#
#     tool :search_knowledge_base
#   end
#
# Then run:
#   agent = Ask::Agent.new("support_bot")
#   agent.run("How do I reset my password?")
#
class ApplicationAgent < Ask::Agent::Definition
  # Default instructions — override in subclasses
  system_prompt "You are a helpful assistant."

  # Uncomment to add built-in tools:
  # tool :bash
  # tool :read
  # tool :grep
end
