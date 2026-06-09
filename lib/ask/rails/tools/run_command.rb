# frozen_string_literal: true

module Ask
  module Rails
    module Tools
      class RunCommand < Ask::Rails::Tool
        description "Run a shell command in the Rails app root directory."
        param :command, type: :string, desc: "Shell command to run", required: true

        def execute(command:)
          output = `cd #{rails_root} && #{command} 2>&1`
          Ask::Result.success(
            data: { output: output, exit_status: $?.exitstatus },
            metadata: { exit_status: $?.exitstatus }
          )
        end
      end
    end
  end
end
