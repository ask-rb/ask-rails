# frozen_string_literal: true

require_relative "test_helper"

class RailtieTest < Minitest::Test
  def test_railtie_ignores_agent_directories_from_zeitwerk
    path = File.expand_path("../lib/ask/rails/railtie.rb", __dir__)
    content = File.read(path)
    assert_includes content, "initializer \"ask_rails.zeitwerk\""
    assert_includes content, "autoloaders.main.ignore"
    assert_includes content, "app/agents"
  end

  def test_railtie_requires_agent_tools_at_boot
    path = File.expand_path("../lib/ask/rails/railtie.rb", __dir__)
    content = File.read(path)
    assert_includes content, "initializer \"ask_rails.agent_tools\""
    assert_includes content, "app/agents/shared/tools"
    assert_includes content, "*/tools/*.rb"
  end

  def test_railtie_loaded_when_rails_present
    assert Ask::Rails::Railtie
  end
end
