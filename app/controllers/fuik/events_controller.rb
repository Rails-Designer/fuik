# frozen_string_literal: true

module Fuik
  class EventsController < Fuik::Engine.config.events_controller_parent.constantize
    layout "fuik/application"

    def index
      @webhook_events = WebhookEvent.filtered(params).order(created_at: :desc)

      respond_to do |format|
        format.html
        format.json { render json: @webhook_events }
      end
    end

    def show
      @webhook_event = WebhookEvent.find(params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @webhook_event }
      end
    end
  end
end
