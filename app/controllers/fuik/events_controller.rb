# frozen_string_literal: true

module Fuik
  class EventsController < Fuik::Engine.config.events_controller_parent.constantize
    layout "fuik/application"

    def index
      @webhook_events = WebhookEvent.order(created_at: :desc)
    end

    def show
      @webhook_event = WebhookEvent.find(params[:id])
    end
  end
end
