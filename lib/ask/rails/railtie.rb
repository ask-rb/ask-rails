# frozen_string_literal: true

module Ask
  module Rails
    class Railtie < ::Rails::Railtie
      generators do
        require_relative "generators/install/install_generator"
      end
    end
  end
end
