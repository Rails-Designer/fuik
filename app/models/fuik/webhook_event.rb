# frozen_string_literal: true

module Fuik
  class WebhookEvent < ApplicationRecord
    self.table_name = "fuik_webhook_events"

    def self.event_class_for(provider, event_type)
      "#{provider.camelize}::#{event_type.tr("./:-[]", "_").camelize}".safe_constantize
    end

    include Filterable

    enum :status, %w[pending processed failed].index_by(&:itself), default: "pending"

    validates :provider, presence: true
    validates :event_id, presence: true

    def payload
      @payload ||= JSON.parse(body)
    rescue JSON::ParserError
      {}
    end

    def processed!
      update!(status: "processed")
    end

    def failed!(error = nil)
      update!(status: "failed", error: error.to_s)
    end

    def retry!
      raise "Can only retry failed events" unless failed?

      update!(status: "pending", error: nil)
      process_later!
    end

    def process_later!
      event_class = self.class.event_class_for(provider, event_type)

      WebhookProcessingJob.perform_later(event_class.name, self) if event_class
    end
  end
end
