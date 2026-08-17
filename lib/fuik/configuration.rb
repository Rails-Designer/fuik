# frozen_string_literal: true

module Fuik
  class Configuration
    attr_accessor :events_controller_parent, :webhooks_controller_parent,
      :providers_allowed, :title, :color_scheme

    def initialize
      @events_controller_parent = "ActionController::Base"
      @webhooks_controller_parent = "ActionController::Base"
      @providers_allowed = nil
      @title = "Webhooks"
      @color_scheme = :light
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
