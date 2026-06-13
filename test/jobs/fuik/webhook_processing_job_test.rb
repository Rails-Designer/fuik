require "test_helper"

module Fuik
  class WebhookProcessingJobTest < ActiveJob::TestCase
    test "processes the webhook event" do
      webhook_event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_job_123",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {}
      )

      WebhookProcessingJob.perform_now("Stripe::CheckoutSessionCompleted", webhook_event)

      assert_equal "processed", webhook_event.reload.status
    end
  end
end
