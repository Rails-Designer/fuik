# frozen_string_literal: true

class Fuik::DownloadsController < ApplicationController
  def create
    webhook_event = Fuik::WebhookEvent.find(params[:event_id])

    send_data webhook_event.body, filename: "webhook_#{webhook_event.provider}_#{webhook_event.event_id}.json", type: "application/json", disposition: "attachment"
  end
end
