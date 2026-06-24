require "test_helper"

module Fuik
  class RetriesControllerTest < ActionDispatch::IntegrationTest
    test "retries a failed event" do
      event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_retry",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {},
        status: "failed",
        error: "Boom"
      )

      post "/webhooks/events/#{event.id}/retries"

      assert_redirected_to "/webhooks/events/#{event.id}"
      assert_equal "processed", event.reload.status
      assert_nil event.reload.error
    end

    test "returns 404 for non-existent event" do
      post "/webhooks/events/99999/retries"

      assert_response :not_found
    end
  end
end
