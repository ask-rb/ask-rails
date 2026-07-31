# frozen_string_literal: true

module Ask
  module Rails
    class Railtie < ::Rails::Railtie
      # ask-agent discovers agents, tools, and skills itself via direct
      # `require` (app/agents/<name>/agent.rb, shared/tools/*.rb, ...).
      # Zeitwerk must not try to autoload those directories — the class
      # names inside (e.g. `NlOperatorAgent`) don't match the Zeitwerk
      # constant mapping (e.g. `NlOperator::Agent`) and eager loading
      # would raise. Keep the directories out of Zeitwerk entirely.
      initializer "ask_rails.zeitwerk" do |app|
        agents_path = app.root.join("app/agents")
        next unless agents_path.directory?

        Dir.glob(agents_path.join("*")).each do |entry|
          ::Rails.autoloaders.main.ignore(entry) if File.directory?(entry)
        end
      end

      # Agent tools (app/agents/shared/tools/*.rb and per-agent
      # app/agents/*/tools/*.rb) are required at boot so the Ask::Tools
      # registry is populated and their constants resolve anywhere —
      # including code compiled before the first agent discovery (e.g. test
      # classes referencing Tools::Billing::InquiryTool). ask-agent's own
      # lazy discovery re-requires them idempotently.
      initializer "ask_rails.agent_tools" do |app|
        agents_path = app.root.join("app/agents")
        next unless agents_path.directory?

        Dir[agents_path.join("shared/tools/*.rb"), agents_path.join("*/tools/*.rb")].uniq.sort.each do |file|
          require file
        end
      end
    end
  end
end
