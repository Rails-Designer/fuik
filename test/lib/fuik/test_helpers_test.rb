require "test_helper"
require "fuik/test_helpers"

module Fuik
  class TestHelpersTest < ActiveSupport::TestCase
    include Fuik::TestHelpers

    test "build_webhook_event returns a WebhookEventDouble" do
      event = build_webhook_event

      assert_kind_of Fuik::TestHelpers::WebhookEventDouble, event
    end

    test "sets provider, event_id, and event_type" do
      event = build_webhook_event(
        provider: "stripe",
        event_id: "evt_123",
        event_type: "checkout.session.completed"
      )

      assert_equal "stripe", event.provider
      assert_equal "evt_123", event.event_id
      assert_equal "checkout.session.completed", event.event_type
    end

    test "payload returns a raw Hash" do
      event = build_webhook_event(payload: { "customer" => "cus_123" })

      assert_equal({ "customer" => "cus_123" }, event.payload)
      assert_kind_of Hash, event.payload
    end

    test "payload defaults to empty Hash" do
      event = build_webhook_event

      assert_equal({}, event.payload)
    end

    test "processed! sets status to processed" do
      event = build_webhook_event

      event.processed!

      assert_equal "processed", event.status
    end

    test "failed! sets status to failed and stores error" do
      event = build_webhook_event

      event.failed!("Network timeout")

      assert_equal "failed", event.status
      assert_equal "Network timeout", event.error
    end

    test "status is nil before any state transition" do
      event = build_webhook_event

      assert_nil event.status
      assert_nil event.error
    end
  end
end
