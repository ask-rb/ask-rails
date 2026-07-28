# frozen_string_literal: true

require_relative "../test_helper"

class InstallGeneratorTest < Minitest::Test
  def test_generator_file_exists
    path = File.expand_path("../../lib/ask/rails/generators/install/install_generator.rb", __dir__)
    assert File.exist?(path), "Generator file should exist at #{path}"
  end

  def test_initializer_template_exists
    path = File.expand_path("../../lib/ask/rails/generators/install/templates/initializer.rb", __dir__)
    assert File.exist?(path), "Initializer template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "Ask::Agent.configure"
  end

  def test_application_agent_template_exists
    path = File.expand_path("../../lib/ask/rails/generators/install/templates/application_agent.rb", __dir__)
    assert File.exist?(path), "Application agent template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "ApplicationAgent < Ask::Agent::Definition"
  end

  def test_railtie_registers_generators
    path = File.expand_path("../../lib/ask/rails/railtie.rb", __dir__)
    assert File.exist?(path), "Railtie file should exist"
    content = File.read(path)
    assert_includes content, "generators"
    assert_includes content, "install_generator"
  end

  def test_version_is_set
    refute_nil Ask::Rails::VERSION
    assert_match(/\A\d+\.\d+\.\d+\z/, Ask::Rails::VERSION)
  end

  def test_entry_point_loads
    assert Ask::Rails
  end
end
