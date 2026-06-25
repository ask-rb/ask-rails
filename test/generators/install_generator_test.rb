# frozen_string_literal: true

require_relative "../test_helper"

class InstallGeneratorTest < Minitest::Test
  def test_generator_file_exists
    path = File.expand_path("../../lib/generators/ask/rails/install/install_generator.rb", __dir__)
    assert File.exist?(path), "Generator file should exist"
  end

  def test_initializer_template_exists
    path = File.expand_path("../../lib/generators/ask/rails/install/templates/initializer.rb", __dir__)
    assert File.exist?(path), "Initializer template should exist"
    content = File.read(path)
    assert_includes content, "Ask::Rails.configure"
    assert_includes content, "default_model"
  end

  def test_migration_template_exists
    path = File.expand_path("../../lib/generators/ask/rails/install/templates/migration.rb", __dir__)
    assert File.exist?(path), "Migration template should exist"
    content = File.read(path)
    assert_includes content, "create_table :ask_sessions"
    assert_includes content, "session_id"
  end

  def test_generates_initializer_content
    path = File.expand_path("../../lib/generators/ask/rails/install/templates/initializer.rb", __dir__)
    content = File.read(path)
    assert_match(/config\.default_model/, content)
    assert_match(/config\.max_turns/, content)
  end

  def test_generates_migration_content
    path = File.expand_path("../../lib/generators/ask/rails/install/templates/migration.rb", __dir__)
    content = File.read(path)
    assert_match(/def change/, content)
    assert_match(/create_table/, content)
  end

  def test_generator_described
    path = File.expand_path("../../lib/generators/ask/rails/install/install_generator.rb", __dir__)
    content = File.read(path)
    assert_includes content, "create_initializer"
    assert_includes content, "create_migration"
    assert_includes content, "create_tools_directory"
  end

  def test_tools_directory_created
    path = File.expand_path("../../lib/generators/ask/rails/install/install_generator.rb", __dir__)
    content = File.read(path)
    assert_includes content, "app/tools"
    assert_includes content, "empty_directory"
  end
end
