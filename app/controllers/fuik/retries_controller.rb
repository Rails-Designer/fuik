# frozen_string_literal: true

module Fuik
  class RetriesController < Fuik::Engine.config.events_controller_parent.constantize
    def create
      webhook_event = WebhookEvent.find(params[:event_id])
      webhook_event.retry!

      redirect_to event_path(webhook_event)
    end
  end
end
