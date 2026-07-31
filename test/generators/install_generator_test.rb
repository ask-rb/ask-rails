# frozen_string_literal: true

require_relative "../test_helper"

class InstallGeneratorTest < Minitest::Test
  def test_generator_file_exists
    path = File.expand_path("../../lib/generators/ask/install_generator.rb", __dir__)
    assert File.exist?(path), "Generator file should exist at #{path}"
    content = File.read(path)
    assert_includes content, "skip_graph"
    assert_includes content, "defined?(Ask::Graph)"
  end

  def test_initializer_template_exists
    path = File.expand_path("../../lib/generators/ask/install/templates/initializer.rb", __dir__)
    assert File.exist?(path), "Initializer template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "Ask::Agent.configure"
    assert_includes content, "Ask::Graph.storage"
    assert_includes content, "defined?(Ask::Graph)"
  end

  def test_application_agent_template_exists
    path = File.expand_path("../../lib/generators/ask/install/templates/application_agent.rb", __dir__)
    assert File.exist?(path), "Application agent template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "ApplicationAgent < Ask::Agent::Definition"
  end

  def test_application_workflow_template_exists
    path = File.expand_path("../../lib/generators/ask/install/templates/application_workflow.rb", __dir__)
    assert File.exist?(path), "Application workflow template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "ApplicationWorkflow < Ask::Graph"
  end

  def test_no_duplicate_generator_paths
    assert File.exist?(File.expand_path("../../lib/generators/ask/install_generator.rb", __dir__))
    refute File.exist?(File.expand_path("../../lib/ask/rails/generators/install/install_generator.rb", __dir__)),
           "Old railtie generator path should be removed — generators live under lib/generators/ask/"
  end

  def test_version_is_set
    refute_nil Ask::Rails::VERSION
    assert_match(/\A\d+\.\d+\.\d+\z/, Ask::Rails::VERSION)
  end

  def test_entry_point_loads
    assert Ask::Rails
  end
end

class AgentGeneratorTest < Minitest::Test
  def test_agent_generator_file_exists
    path = File.expand_path("../../lib/generators/ask/agent_generator.rb", __dir__)
    assert File.exist?(path), "Agent generator file should exist at #{path}"
    content = File.read(path)
    assert_includes content, "NamedBase"
    assert_includes content, "file_name"
  end

  def test_agent_template_exists
    path = File.expand_path("../../lib/generators/ask/agent/templates/agent.rb", __dir__)
    assert File.exist?(path), "Agent template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "class <%= class_name %> < ApplicationAgent"
    assert_includes content, "module Agents"
    assert_includes content, "class_name"
  end
end

class WorkflowGeneratorTest < Minitest::Test
  def test_workflow_generator_file_exists
    path = File.expand_path("../../lib/generators/ask/workflow_generator.rb", __dir__)
    assert File.exist?(path), "Workflow generator file should exist at #{path}"
    content = File.read(path)
    assert_includes content, "NamedBase"
    assert_includes content, "verify_ask_graph"
  end

  def test_workflow_template_exists
    path = File.expand_path("../../lib/generators/ask/workflow/templates/workflow.rb", __dir__)
    assert File.exist?(path), "Workflow template should exist at #{path}"
    content = File.read(path)
    assert_includes content, "class Workflow < ApplicationWorkflow"
    assert_includes content, "class_name"
  end
end
