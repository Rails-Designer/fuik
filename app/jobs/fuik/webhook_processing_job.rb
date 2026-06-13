module Fuik
  class WebhookProcessingJob < ApplicationJob
    def perform(event_class_name, webhook_event)
      Object.const_get(event_class_name).new(webhook_event).process!
    end
  end
end
