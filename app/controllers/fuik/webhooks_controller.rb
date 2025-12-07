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
        body: request.raw_post,
        headers: headers
      )

      process!(webhook_event)

      head :ok
    rescue Fuik::InvalidSignature
      head :unauthorized
    rescue ActiveRecord::RecordNotUnique
      head :ok
    end

    private

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

        JSON.parse(request.raw_post)
      rescue JSON::ParserError
        {}
      end
    end

    def process!(webhook_event)
      event_class = event_class_for(webhook_event.provider, webhook_event.event_type)
      return unless event_class

      event_class.new(webhook_event).process!
    end

    def event_class_for(provider, event_type)
      "#{provider.camelize}::#{event_type.tr("./:-", "_").camelize}".safe_constantize
    end

    def should_verify? = base_class&.respond_to?(:verify!)

    def base_class
      @base_class ||= "#{params[:provider].camelize}::Base".safe_constantize
    end
  end
end
