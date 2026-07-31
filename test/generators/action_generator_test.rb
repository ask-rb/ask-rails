# frozen_string_literal: true

require_relative "../test_helper"

class ActionGeneratorTest < Minitest::Test
  def test_action_generator_file_exists
    path = File.expand_path("../../lib/generators/ask/action_generator.rb", __dir__)
    assert File.exist?(path), "Generator file should exist at #{path}"
    content = File.read(path)
    assert_includes content, "NamedBase"
    assert_includes content, "file_name"
    assert_includes content, "args"
  end

  def test_action_template_exists
    path = File.expand_path("../../lib/generators/ask/action/templates/action.rb", __dir__)
    assert File.exist?(path), "Action template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "class <%= action_class_name %> < ApplicationAction"
    assert_includes content, "dispatch_name"
    assert_includes content, "Ask::Actions.dispatch"
    assert_includes content, "Ask::Actions::Result.ok"
  end
end

class ActionInstallTest < Minitest::Test
  def test_install_generator_creates_actions_directory
    path = File.expand_path("../../lib/generators/ask/install_generator.rb", __dir__)
    content = File.read(path)
    assert_includes content, "app/actions"
  end

  def test_application_action_template_exists
    path = File.expand_path("../../lib/generators/ask/install/templates/application_action.rb", __dir__)
    assert File.exist?(path), "Application action template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "class ApplicationAction"
    assert_includes content, "def self.call(context:, params: {})"
    assert_includes content, "Ask::Actions::Result.ok"
  end

  def test_initializer_documents_actions
    path = File.expand_path("../../lib/generators/ask/install/templates/initializer.rb", __dir__)
    content = File.read(path)
    assert_includes content, "Ask::Actions.dispatch"
    assert_includes content, "Ask::Actions.register"
  end
end
