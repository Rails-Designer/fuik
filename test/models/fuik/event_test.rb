require "test_helper"

module Fuik
  class EventTest < ActiveSupport::TestCase
    def setup
      webhook_event = Class.new do
        attr_reader :payload

        def initialize(payload)
          @payload = payload
        end
      end

      @webhook_event = webhook_event.new({
        "client_reference_id" => "user_123",
        "type" => "checkout.session.completed",
        "customer" => { "email" => "test@example.com" }
      })
      @event = Event.new(@webhook_event)
    end

    test "supports dot notation access" do
      assert_equal "user_123", @event.payload.client_reference_id
      assert_equal "checkout.session.completed", @event.payload.type
    end

    test "supports hash syntax access" do
      assert_equal "user_123", @event.payload["client_reference_id"]
      assert_equal "test@example.com", @event.payload.dig("customer", "email")
    end
  end
end
