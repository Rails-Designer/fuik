# frozen_string_literal: true

module Fuik
  class WebhookEvent < ApplicationRecord
    self.table_name = "fuik_webhook_events"

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

    def failed!(error)
      update!(status: "failed", error: error.to_s)
    end
  end
end
