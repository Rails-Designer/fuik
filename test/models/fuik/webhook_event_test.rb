require "test_helper"

module Test
  class Test < Fuik::Event
    def process!
      @webhook_event.processed!
    end
  end

  class ProcessingJob < ActiveJob::Base
    cattr_accessor :performed, default: false

    def perform(*)
      self.class.performed = true
    end
  end
end

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

    test "process_later! uses configured job class" do
      original = Fuik.webhook_processing_job_class
      event = WebhookEvent.create!(
        provider: "test",
        event_id: "evt_cfg_1",
        event_type: "test",
        body: {}.to_json,
        headers: {}
      )

      Fuik.configure { it.webhook_processing_job_class = "Test::ProcessingJob" }

      event.process_later!

      assert Test::ProcessingJob.performed
    ensure
      Fuik.webhook_processing_job_class = original
      Test::ProcessingJob.performed = false
    end
  end
end
