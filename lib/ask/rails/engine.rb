# frozen_string_literal: true

require_relative "railtie"

module Ask
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Ask::Rails
    end
  end
end
