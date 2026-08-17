# frozen_string_literal: true

module Fuik
  module TestHelpers
    def build_webhook_event(provider: "test", event_id: "test_123", event_type: "test", payload: {})
      WebhookEventDouble.new(provider, event_id, event_type, payload)
    end

    class WebhookEventDouble
      attr_reader :provider, :event_id, :event_type, :status, :error

      def initialize(provider, event_id, event_type, payload)
        @provider = provider
        @event_id = event_id
        @event_type = event_type
        @payload = payload
      end

      def payload
        @payload.is_a?(Hash) ? @payload : {}
      end

      def processed!
        @status = "processed"
      end

      def failed!(error)
        @status = "failed"
        @error = error.to_s
      end
    end
  end
end
