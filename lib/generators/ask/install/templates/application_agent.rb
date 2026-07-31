# frozen_string_literal: true

# Base class for your application's AI agents.
#
# Subclass this to define agents:
#
#   # app/agents/support_bot/agent.rb
#   module SupportBot
#     class Agent < ApplicationAgent
#       model "gpt-4o"
#       tools :search_knowledge_base
#     end
#   end
#
#   # app/agents/support_bot/instructions.md — auto-loaded as the system prompt
#   # app/agents/support_bot/tools/search_knowledge_base.rb — per-agent tools
#
# Then run:
#   agent = Ask::Agent.new("support_bot")
#   agent.run("How do I reset my password?")
#
class ApplicationAgent < Ask::Agent::Definition
  # Default instructions — override by adding an instructions.md file
  # in the agent directory, or with option :system_prompt, "..."
end
