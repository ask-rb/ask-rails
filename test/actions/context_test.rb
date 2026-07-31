# frozen_string_literal: true

require_relative "../test_helper"

class ContextTest < Minitest::Test
  def test_attributes_become_accessors
    user = Object.new
    session = Object.new
    context = Ask::Actions::Context.new(user: user, session: session)

    assert_same user, context.user
    assert_same session, context.session
  end

  def test_attributes_are_writable
    context = Ask::Actions::Context.new(workspace: :dental_clinic)
    context.workspace = :auto_shop

    assert_equal :auto_shop, context.workspace
  end

  def test_any_attribute_name_is_supported
    context = Ask::Actions::Context.new(voice_call: 42, patient: :jane)

    assert_equal 42, context.voice_call
    assert_equal :jane, context.patient
  end

  def test_empty_initialization
    context = Ask::Actions::Context.new

    assert_instance_of Ask::Actions::Context, context
  end

  def test_instances_are_independent
    first = Ask::Actions::Context.new(workspace: :one)
    second = Ask::Actions::Context.new(workspace: :two)

    assert_equal :one, first.workspace
    assert_equal :two, second.workspace
  end
end
