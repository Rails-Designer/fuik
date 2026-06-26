# frozen_string_literal: true

module Fuik
  class Event
    using DotAccess

    def initialize(webhook_event)
      @webhook_event = webhook_event
    end

    # Called when the webhook event is processed. Override to handle the event
    # payload and transition the event's status to processed or failed.
    #
    # @return [void]
    #
    # @example Implementing a checkout.session.completed handler
    #   def process!
    #     User.find_by(id: payload.client_reference_id).tap do |user|
    #       user.activate_subscription!
    #       user.send_welcome_email
    #     end
    #
    #     @webhook_event.processed!
    #   end
    def process!
      raise NotImplementedError, "#{self.class} must implement #process!"
    end

    # Access the webhook payload with dot notation or standard hash access.
    #
    # @return [Fuik::DotAccess::AccessPayload] the parsed JSON body wrapped in a dot-accessible object
    #
    # @example Dot notation
    #   payload.customer.email
    #
    # @example Hash access
    #   payload["line_items"][0]["product_id"]
    def payload
      @webhook_event.payload.to_dot
    end
  end
end
