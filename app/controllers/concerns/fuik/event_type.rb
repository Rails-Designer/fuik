# frozen_string_literal: true

module Fuik
  module EventType
    private

    COMMON_EVENT_TYPE_HEADERS = [
      "X-Github-Event",
      "X-Event-Type",
      "X-Webhook-Event"
    ]

    COMMON_EVENT_ID_HEADERS = [
      "X-GitHub-Delivery",
      "X-Event-Id",
      "X-Webhook-Id"
    ]

    def event_type
      from_config("event_type") || from_event_type_headers || from_payload_type || "unknown"
    end

    def event_id
      from_config("event_id") || from_event_id_headers || payload["id"] || Digest::MD5.hexdigest(request.raw_post)
    end

    def from_config(key)
      return unless config.present? && config[key].present?

      case config[key]["source"]
      when "header"
        request.headers[config[key]["key"]]
      when "payload"
        payload[config[key]["key"]]
      end
    end

    def from_event_type_headers
      COMMON_EVENT_TYPE_HEADERS.lazy.map { |header| request.headers[header] }.find(&:present?)
    end

    def from_event_id_headers
      COMMON_EVENT_ID_HEADERS.lazy.map { |header| request.headers[header] }.find(&:present?)
    end

    def from_payload_type
      payload["type"] || payload["event"] || payload["event_type"]
    end

    def config
      @config ||= begin
        config_path = Rails.root.join("app/webhooks/#{params[:provider]}/config.yml")

        File.exist?(config_path) ? YAML.load_file(config_path) : nil
      end
    end
  end
end
