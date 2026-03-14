# frozen_string_literal: true

module Fuik
  class Event
    using DotAccess

    def initialize(webhook_event)
      @webhook_event = webhook_event
    end

    def process!
      raise NotImplementedError, "#{self.class} must implement #process!"
    end

    def payload
      @webhook_event.payload.to_dot
    end
  end
end
