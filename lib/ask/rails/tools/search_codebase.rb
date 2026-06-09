# frozen_string_literal: true

module Ask
  module Rails
    module Tools
      class SearchCodebase < Ask::Rails::Tool
        description "Search the Rails codebase with grep."
        param :pattern, type: :string, desc: "Search pattern", required: true
        param :path, type: :string, desc: "Subdirectory to search (optional)"

        def execute(pattern:, path: nil)
          search_path = path ? rails_root.join(path) : rails_root
          results = `cd #{rails_root} && grep -rn '#{pattern}' #{search_path} 2>&1 | head -50`
          Ask::Result.success(
            data: { results: results, count: results.lines.count },
            metadata: { pattern: pattern, count: results.lines.count }
          )
        end
      end
    end
  end
end
