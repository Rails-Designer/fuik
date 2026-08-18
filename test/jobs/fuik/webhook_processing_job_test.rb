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

      ActiveSupport::Notifications.subscribed(->(name, payload) { events << [name, payload] }, "webhook_processed.fuik") do
        WebhookProcessingJob.perform_now("Stripe::CheckoutSessionCompleted", webhook_event)
      end
    end

    test "publishes webhook_failed notification on processing error" do
      events = []

      webhook_event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_job_fail",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {}
      )

      ActiveSupport::Notifications.subscribed(->(name, payload) { events << [name, payload] }, "webhook_failed.fuik") do
        assert_raises(NameError) do
          WebhookProcessingJob.perform_now("NonExistent::Class", webhook_event)
        end
      end

      assert_equal 1, events.size
      assert_equal "webhook_failed.fuik", events.first[0]
      assert events.first[1][:error].is_a?(NameError)
      assert_equal "NonExistent::Class", events.first[1][:event_class]
    end

    test "marks event as failed when processing raises" do
      webhook_event = WebhookEvent.create!(
        provider: "stripe",
        event_id: "evt_job_fail2",
        event_type: "checkout.session.completed",
        body: {}.to_json,
        headers: {}
      )

      assert_raises(NameError) do
        WebhookProcessingJob.perform_now("NonExistent::Class", webhook_event)
      end

      assert_equal "failed", webhook_event.reload.status
    end
  end
end
