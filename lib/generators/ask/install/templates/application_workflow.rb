# frozen_string_literal: true

# Base class for your application's workflows.
#
# Subclass this to define workflows:
#
#   module OrderFulfillment
#     class Workflow < ApplicationWorkflow
#       step ValidatePayment
#       step NotifyCustomer
#       step ShipOrder
#     end
#   end
#
# Then run:
#   result = OrderFulfillment::Workflow.call({ order: order })
#
class ApplicationWorkflow < Ask::Graph
  # Shared defaults — uncomment as needed:
  # step_timeout 30
  # workflow_timeout 60
  # storage PostgresStore.new
end
