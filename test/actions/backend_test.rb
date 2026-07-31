# frozen_string_literal: true

require_relative "../test_helper"

module Chats
  class Create
    def self.call(context:, params:)
      Ask::Actions::Result.ok(
        message: "Chat created",
        data: { user: context.user, params: params }
      )
    end
  end
end

module ApiTokens
  class Create
    def self.call(context:, params:)
      Ask::Actions::Result.ok(message: "Token created", data: { params: params })
    end
  end
end

class CustomOperation
  def self.call(context:, params:)
    Ask::Actions::Result.ok(message: "Custom op")
  end
end

class BackendTest < Minitest::Test
  def teardown
    Ask::Actions.reset!
  end

  def test_convention_resolves_namespaced_action
    result = Ask::Actions.dispatch(action: "chats.create", context: Ask::Actions::Context.new(user: :some_user))

    assert result.ok?
    assert_equal "Chat created", result.message
  end

  def test_convention_resolves_snake_case_constants
    result = Ask::Actions.dispatch(action: "api_tokens.create", context: Ask::Actions::Context.new)

    assert result.ok?
    assert_equal "Token created", result.message
  end

  def test_dispatch_passes_context_and_params
    user = Object.new
    result = Ask::Actions.dispatch(
      action: "chats.create",
      context: Ask::Actions::Context.new(user: user),
      params: { name: "general" }
    )

    assert_same user, result.data[:user]
    assert_equal({ name: "general" }, result.data[:params])
  end

  def test_registered_action_takes_precedence_over_convention
    Ask::Actions.register("chats.create", CustomOperation)

    result = Ask::Actions.dispatch(action: "chats.create", context: Ask::Actions::Context.new)

    assert_equal "Custom op", result.message
  end

  def test_registered_action_works_without_convention_class
    Ask::Actions.register("custom.op", CustomOperation)

    result = Ask::Actions.dispatch(action: "custom.op", context: Ask::Actions::Context.new)

    assert result.ok?
    assert_equal "Custom op", result.message
  end

  def test_unknown_action_raises
    error = assert_raises(Ask::Actions::Backend::UnknownAction) do
      Ask::Actions.dispatch(action: "nope.not_real", context: Ask::Actions::Context.new)
    end

    assert_includes error.message, "nope.not_real"
    assert_includes error.message, "app/actions"
  end

  def test_invalid_action_name_is_never_constantized
    error = assert_raises(Ask::Actions::Backend::UnknownAction) do
      Ask::Actions.dispatch(action: "Chats::Create; puts 1", context: Ask::Actions::Context.new)
    end

    assert_includes error.message, "Chats::Create; puts 1"
  end

  def test_available_lists_registered_actions
    Ask::Actions.register("chats.create", Chats::Create)

    assert_equal ["chats.create"], Ask::Actions.available
  end

  def test_reset_clears_registry
    Ask::Actions.register("custom.op", CustomOperation)
    Ask::Actions.reset!

    assert_empty Ask::Actions.available
    assert_raises(Ask::Actions::Backend::UnknownAction) do
      Ask::Actions.dispatch(action: "custom.op", context: Ask::Actions::Context.new)
    end
  end

  def test_resolve_returns_class
    assert_equal Chats::Create, Ask::Actions.resolve("chats.create")
  end
end
