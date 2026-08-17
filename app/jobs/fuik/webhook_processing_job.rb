module Fuik
  class WebhookProcessingJob < ApplicationJob
    def perform(event_class_name, webhook_event)
      Object.const_get(event_class_name).new(webhook_event).process!

      Notifications.processed(
        webhook_event: webhook_event,
        event_class: event_class_name
      )
    rescue => error
      webhook_event.failed!(error)

      Notifications.failed(
        webhook_event: webhook_event,
        event_class: event_class_name,
        error: error
      )

      raise
    end
  end
end
