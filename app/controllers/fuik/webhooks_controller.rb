# frozen_string_literal: true

module Fuik
  class WebhooksController < Fuik::Engine.config.webhooks_controller_parent.constantize
    include EventType

    skip_before_action :verify_authenticity_token

    def create
      verify_signature!

      webhook_event = WebhookEvent.create!(
        provider: params[:provider],
        event_id: event_id,
        event_type: event_type,
        body: json_body,
        headers: headers
      )

      Notifications.received(
        provider: params[:provider],
        event_id: event_id,
        event_type: event_type,
        webhook_event: webhook_event
      )

      webhook_event.process_later!

      head :ok
    rescue Fuik::InvalidSignature
      Notifications.signature_invalid(
        provider: params[:provider],
        event_id: event_id
      )
      head :unauthorized
    rescue ActiveRecord::RecordNotUnique
      head :ok
    rescue => error
      Notifications.receive_error(
        provider: request.path_parameters[:provider],
        error: error
      )
      head :internal_server_error
    end

    private

    def json_body
      return request.raw_post unless url_encoded_body?

      Rack::Utils.parse_nested_query(request.raw_post).to_json
    end

    def verify_signature!
      return unless should_verify?

      base_class.verify!(request)
    end

    def headers
      @headers ||= request.headers.env
        .select { |key, _| key.start_with?("HTTP_") }
        .transform_keys { |key| key.sub(/^HTTP_/, "").split("_").map(&:capitalize).join("-") }
        .merge(request.content_type.present? ? {"Content-Type" => request.content_type} : {})
    end

    def payload
      @payload ||= begin
        return {} if request.raw_post.blank?

        JSON.parse(json_body)
      rescue JSON::ParserError
        {}
      end
    end

    def process!(webhook_event)
      event_class = WebhookEvent.event_class_for(webhook_event.provider, webhook_event.event_type)
      return unless event_class

      event_class.new(webhook_event).process!
    end

    def url_encoded_body?
      request.media_type == "application/x-www-form-urlencoded"
    end

    def should_verify? = base_class&.respond_to?(:verify!)

    def base_class
      @base_class ||= "#{params[:provider].camelize}::Base".safe_constantize
    end
  end
end
