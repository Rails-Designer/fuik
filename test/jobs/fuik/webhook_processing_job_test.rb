require "test_helper"

module Fuik
  class FailingEvent < Event
    def process!
      raise "ProcessingError"
    end
  end

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

    test "transitions event to failed state when processing raises" do
      webhook_event = WebhookEvent.create!(
        provider: "test",
        event_id: "evt_fail_1",
        event_type: "test",
        body: {}.to_json,
        headers: {}
      )

      assert_raises(RuntimeError) do
        WebhookProcessingJob.perform_now("Fuik::FailingEvent", webhook_event)
      end

      assert_equal "failed", webhook_event.reload.status
      assert_equal "ProcessingError", webhook_event.error
    end
  end
end
