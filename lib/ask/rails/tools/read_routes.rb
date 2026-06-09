# frozen_string_literal: true

module Ask
  module Rails
    module Tools
      class ReadRoutes < Ask::Rails::Tool
        description "Read the Rails routes from config/routes.rb"
        def execute
          routes_file = rails_root.join("config", "routes.rb")
          return Ask::Result.error(message: "No routes file found") unless routes_file.exist?

          content = routes_file.read
          Ask::Result.success(
            data: { content: content },
            metadata: { size: content.length }
          )
        end
      end
    end
  end
end
