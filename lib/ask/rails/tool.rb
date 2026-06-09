# frozen_string_literal: true

module Ask
  module Rails
    class Tool < Ask::Tool
      def rails_root
        ::Rails.root
      end
    end
  end
end
