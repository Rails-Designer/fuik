module Fuik
  class WebhookProcessingJob < ApplicationJob
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(event_class_name, webhook_event)
      Object.const_get(event_class_name).new(webhook_event).process!
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
