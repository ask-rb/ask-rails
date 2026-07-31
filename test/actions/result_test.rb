# frozen_string_literal: true

require_relative "../test_helper"

class ResultTest < Minitest::Test
  def test_ok_constructor
    result = Ask::Actions::Result.ok(message: "Done", data: { id: 1 }, code: :created, redirect_path: "/bookings/1")

    assert result.ok?
    refute result.error?
    assert_equal "Done", result.message
    assert_equal({ id: 1 }, result.data)
    assert_equal :created, result.code
    assert_equal "/bookings/1", result.redirect_path
  end

  def test_error_constructor
    result = Ask::Actions::Result.error(message: "Failed", data: { field: "name" }, code: :validation)

    refute result.ok?
    assert result.error?
    assert_equal "Failed", result.message
    assert_equal({ field: "name" }, result.data)
    assert_equal :validation, result.code
  end

  def test_defaults
    result = Ask::Actions::Result.ok

    assert result.ok?
    assert_equal "", result.message
    assert_equal({}, result.data)
    assert_nil result.code
    assert_nil result.redirect_path
  end

  def test_to_h
    result = Ask::Actions::Result.ok(message: "Done", data: { id: 1 }, code: :created, redirect_path: "/bookings/1")

    assert_equal({ ok: true, message: "Done", data: { id: 1 }, code: :created, redirect_path: "/bookings/1" }, result.to_h)
  end
end
