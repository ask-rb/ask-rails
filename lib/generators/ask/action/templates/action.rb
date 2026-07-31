# frozen_string_literal: true

# <%= dispatch_name %> action.
#
# Dispatch it from any channel — web, Slack, voice:
#   Ask::Actions.dispatch(action: "<%= dispatch_name %>", context: context, params: {})
#
# Return an Ask::Actions::Result:
#   Ask::Actions::Result.ok(message: "Done", data: { id: record.id })
<% if namespaced? -%>
module <%= namespace_class_name %>
  class <%= action_class_name %> < ApplicationAction
    # def call
    #   Ask::Actions::Result.ok(message: "Done")
    # end
  end
end
<% else -%>
class <%= action_class_name %> < ApplicationAction
  # def call
  #   Ask::Actions::Result.ok(message: "Done")
  # end
end
<% end -%>
