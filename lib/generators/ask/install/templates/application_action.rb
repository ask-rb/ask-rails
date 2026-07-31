# frozen_string_literal: true

# Base class for your application's actions.
#
# Subclass this to define actions — operations callable from any channel
# (web, Slack, voice) by name:
#
#   module Chats
#     class Create < ApplicationAction
#       def call
#         chat = context.channel.start_new_chat!
#         Ask::Actions::Result.ok(message: "Chat created", data: { chat: chat })
#       end
#     end
#   end
#
# Then dispatch from anywhere:
#   Ask::Actions.dispatch(action: "chats.create", context: context, params: {})
#
class ApplicationAction
  def self.call(context:, params: {})
    new(context: context, params: params).call
  end

  def initialize(context:, params: {})
    @context = context
    @params = params
  end

  private

  attr_reader :context, :params
end
