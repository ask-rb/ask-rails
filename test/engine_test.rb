# frozen_string_literal: true

require_relative "test_helper"

class EngineTest < Minitest::Test
  def test_ask_rails_module_exists
    assert_kind_of Module, Ask::Rails
  end

  def test_engine_file_exists
    engine_path = File.expand_path("../lib/ask/rails/engine.rb", __dir__)
    assert File.exist?(engine_path), "Engine file should exist"
  end

  def test_railtie_file_exists
    railtie_path = File.expand_path("../lib/ask/rails/railtie.rb", __dir__)
    assert File.exist?(railtie_path), "Railtie file should exist"
  end

  def test_engine_configures_generators
    engine_path = File.expand_path("../lib/ask/rails/engine.rb", __dir__)
    content = File.read(engine_path)
    assert_includes content, "isolate_namespace"
    # engine is minimal, just checks structure
    assert_includes content, "isolate_namespace"
  end

  def test_railtie_configures_rails
    railtie_path = File.expand_path("../lib/ask/rails/railtie.rb", __dir__)
    content = File.read(railtie_path)
    assert_includes content, "Railtie"
  end

  def test_configuration_file_exists
    config_path = File.expand_path("../lib/ask/rails/configuration.rb", __dir__)
    assert File.exist?(config_path)
    content = File.read(config_path)
    assert_includes content, "default_model"
    assert_includes content, "max_turns"
  end

  def test_ask_rails_module_responds_to_version
    assert Ask::Rails.const_defined?(:VERSION)
  end
end
