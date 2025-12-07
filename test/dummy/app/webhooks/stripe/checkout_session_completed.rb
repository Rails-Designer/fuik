# frozen_string_literal: true

module Stripe
  class CheckoutSessionCompleted < Base
    def process!
      # whatever business logic…

      @webhook_event.processed!
    end
  end
end
