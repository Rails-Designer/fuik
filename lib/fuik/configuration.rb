# frozen_string_literal: true

module Fuik
  class Configuration
    attr_writer :dashboard_enabled
    attr_accessor :events_controller_parent, :webhooks_controller_parent,
      :providers_allowed, :title, :color_scheme, :webhook_processing_job_class

    def initialize
      @events_controller_parent = "ActionController::Base"
      @webhooks_controller_parent = "ActionController::Base"
      @webhook_processing_job_class = "Fuik::WebhookProcessingJob"
      @providers_allowed = nil
      @title = "Webhooks"
      @color_scheme = :light
    end

    def dashboard_enabled? = @dashboard_enabled.nil? ? local_env? : @dashboard_enabled

    private

    def local_env? = Rails.env.development? || Rails.env.test?
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    delegate :webhook_processing_job_class, :webhook_processing_job_class=, to: :configuration
  end
end
