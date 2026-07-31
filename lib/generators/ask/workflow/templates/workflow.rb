# frozen_string_literal: true

# <%= class_name %> workflow.
#
# Define steps as plain Ruby classes in steps/ — each responds to call(context).
# Compose other workflows via Workflow.call(context) inside a step.
#
#   module <%= class_name %>
#     class Workflow < ApplicationWorkflow
#       step SomeStep
#       step OtherStep, if: :condition?
#
#       private
#
#       def condition?
#         context.some_flag
#       end
#     end
#   end
#
# Run it:
#   result = <%= class_name %>::Workflow.call({ input: value })
#
module <%= class_name %>
  class Workflow < ApplicationWorkflow
    # step SomeStep
  end
end
