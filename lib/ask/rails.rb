# frozen_string_literal: true

require "ask/agent"

module Ask
  module Rails
  end
end

require_relative "rails/version"
require_relative "rails/railtie" if defined?(::Rails::Railtie)
