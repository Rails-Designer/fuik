# frozen_string_literal: true

module Fuik
  module EventType
    private

    COMMON_EVENT_TYPE_HEADERS = [
      "X-Event-Type",
      "X-Webhook-Event",
      "Webhook-Event"
    ]

    COMMON_EVENT_ID_HEADERS = [
      "X-Event-Id",
      "X-Webhook-Id",
      "Webhook-Id",
      "webhook-id"
    ]

    def event_type
      from_base_class_event_type || from_config("event_type") || from_event_type_headers || from_payload_type || "unknown"
    end

    def event_id
      from_base_class_event_id || from_config("event_id") || from_event_id_headers || payload["id"] || Digest::MD5.hexdigest(request.raw_post)
    end

    def from_base_class_event_type
      config = base_class&.event_type_config

      return if !config
      return config if config.is_a?(String)
      return request.headers[config[:header]] if config.key?(:header)

      payload.dig(*config[:payload].to_s.split(".")) if config.key?(:payload)
    end

    def from_base_class_event_id
      config = base_class&.event_id_config

      return if !config
      return config if config.is_a?(String)
      return request.headers[config[:header]] if config.key?(:header)

      payload.dig(*config[:payload].to_s.split(".")) if config.key?(:payload)
    end

    def from_config(key)
      return unless config.present? && config[key].present?

      case config[key]["source"]
      when "header"
        request.headers[config[key]["key"]]
      when "payload"
        payload[config[key]["key"]]
      when "static"
        config[key]["value"]
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

        if File.exist?(config_path)
          Fuik.deprecator.warn("Using config.yml is deprecated. Define event_type/event_id on #{params[:provider].camelize}::Base instead.")

          YAML.load_file(config_path)
        end
      end
    end
  end
end
