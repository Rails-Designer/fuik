require "test_helper"

module Fuik
  class WebhookEventTest < ActiveSupport::TestCase
    test "retry! resets and reprocesses a failed event" do
      event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_retry_1",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {},
        status: "failed",
        error: "Something went wrong"
      )

      event.retry!

      assert_equal "processed", event.reload.status
      assert_nil event.reload.error
    end

    test "retry! raises for processed events" do
      event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_retry_2",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {},
        status: "processed"
      )

      assert_raises(RuntimeError, match: /failed/) { event.retry! }
    end

    test "retry! raises for pending events" do
      event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_retry_3",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {},
        status: "pending"
      )

      assert_raises(RuntimeError, match: /failed/) { event.retry! }
    end
  end
end
