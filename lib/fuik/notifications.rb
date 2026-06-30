# frozen_string_literal: true

module Fuik
  module Notifications
    class << self
      def received(provider:, event_id:, event_type:, webhook_event:)
        publish("webhook_received",
          provider: provider,
          event_id: event_id,
          event_type: event_type,
          webhook_event: webhook_event)
      end

      def processed(webhook_event:, event_class:)
        publish("webhook_processed",
          provider: webhook_event.provider,
          event_id: webhook_event.event_id,
          event_type: webhook_event.event_type,
          event_class: event_class,
          webhook_event: webhook_event)
      end

      def failed(webhook_event:, event_class:, error:)
        publish("webhook_failed",
          provider: webhook_event.provider,
          event_id: webhook_event.event_id,
          event_type: webhook_event.event_type,
          event_class: event_class,
          error: error,
          webhook_event: webhook_event)
      end

      def signature_invalid(provider:, event_id:)
        publish("webhook_signature_invalid", provider: provider, event_id: event_id)
      end

      def receive_error(provider:, error:)
        publish("webhook_receive_error", provider: provider, error: error)
      end

      private

      def publish(name, payload = {})
        ActiveSupport::Notifications.publish("#{name}.fuik", payload)
      end
    end
  end
end
