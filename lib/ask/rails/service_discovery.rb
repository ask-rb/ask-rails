# frozen_string_literal: true

module Ask
  module Rails
    module ServiceDiscovery
      SERVICE_GEMS_PATTERN = /\Aask-(?!tools|tools-shell|agent|rails|core|auth|schema|llm)/

      module_function

      def discover!
        service_gems = Gem.loaded_specs.keys.select { |name| name.match?(SERVICE_GEMS_PATTERN) }
        contexts = []

        service_gems.each do |name|
          begin
            require "#{name.tr("-", "/")}/context"
            mod = name.camelize.constantize
            contexts << mod if mod.const_defined?(:DESCRIPTION)
          rescue LoadError, NameError
            # No context module for this gem
          end
        end

        unless contexts.empty?
          prompt = build_system_prompt(contexts)
          existing = Ask::Rails.configuration.system_prompt
          Ask::Rails.configuration.system_prompt = [existing, prompt].compact.join("\n\n")
        end

        contexts
      end

      def build_system_prompt(contexts)
        sections = ["## Available Services"]

        contexts.each do |mod|
          sections << "### #{mod.name.demodulize}"
          sections << mod::DESCRIPTION if mod.const_defined?(:DESCRIPTION)
          sections << "Documentation: #{mod::DOCS_URL}" if mod.const_defined?(:DOCS_URL)
          sections << "Authentication: #{mod::AUTH_HOW}" if mod.const_defined?(:AUTH_HOW)
          sections << ""
        end

        sections.join("\n")
      end
    end
  end
end
