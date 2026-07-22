# frozen_string_literal: true

module Ask
  module Rails
    module Tools
      class RunCommand < Ask::Rails::Tool
        description "Run a shell command in the Rails app root directory."
        param :command, type: :string, desc: "Shell command to run", required: true

        def execute(command:)
          check_result = check_command_allowed(command)
          return check_result if check_result

          output = `cd #{rails_root} && #{command} 2>&1`
          Ask::Result.ok(
            data: { output: output, exit_status: $?.exitstatus },
            metadata: { exit_status: $?.exitstatus }
          )
        end

        private

        def check_command_allowed(command)
          config = Ask::Rails.configuration

          # 1. Check denied commands first (takes precedence)
          if config.denied_commands
            config.denied_commands.each do |pattern|
              if command.match?(pattern)
                return Ask::Result.error(
                  message: "Command blocked by deny rule: #{pattern.inspect}"
                )
              end
            end
          end

          # 2. Check allowed commands (if configured)
          if config.allowed_commands
            matches = config.allowed_commands.any? { |pattern| command.match?(pattern) }
            unless matches
              allowed_desc = config.allowed_commands.map(&:inspect).join(", ")
              return Ask::Result.error(
                message: "Command blocked: does not match any allowed pattern (#{allowed_desc})"
              )
            end
          end

          # 3. No restrictions configured — allow
          nil
        end
      end
    end
  end
end
