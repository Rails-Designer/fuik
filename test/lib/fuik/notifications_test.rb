require "test_helper"

module Fuik
  class NotificationsTest < ActiveSupport::TestCase
    test "received publishes webhook_received.fuik" do
      events = []

      webhook_event = WebhookEvent.new

      ActiveSupport::Notifications.subscribed(->(*args) { events << args }, /\.fuik$/) do
        Notifications.received(provider: "stripe", event_id: "evt_1", event_type: "checkout.session.completed", webhook_event: webhook_event)
      end

      assert_equal 1, events.size
      assert_equal "webhook_received.fuik", events.first[0]
      assert_equal "stripe", events.first[1][:provider]
      assert_equal "evt_1", events.first[1][:event_id]
      assert_equal "checkout.session.completed", events.first[1][:event_type]
      assert_same webhook_event, events.first[1][:webhook_event]
    end

    test "processed publishes webhook_processed.fuik" do
      events = []

      webhook_event = WebhookEvent.new

      ActiveSupport::Notifications.subscribed(->(*args) { events << args }, /\.fuik$/) do
        Notifications.processed(webhook_event: webhook_event, event_class: "Stripe::CheckoutSessionCompleted")
      end

      assert_equal 1, events.size
      assert_equal "webhook_processed.fuik", events.first[0]
    end

    test "failed publishes webhook_failed.fuik with error" do
      events = []

      webhook_event = WebhookEvent.new
      error = RuntimeError.new("processing failed")

      ActiveSupport::Notifications.subscribed(->(*args) { events << args }, /\.fuik$/) do
        Notifications.failed(webhook_event: webhook_event, event_class: "Stripe::CheckoutSessionCompleted", error: error)
      end

      assert_equal 1, events.size
      assert_equal "webhook_failed.fuik", events.first[0]
      assert_equal error, events.first[1][:error]
    end

    test "signature_invalid publishes webhook_signature_invalid.fuik" do
      events = []

      ActiveSupport::Notifications.subscribed(->(*args) { events << args }, /\.fuik$/) do
        Notifications.signature_invalid(provider: "stripe", event_id: "evt_bad")
      end

      assert_equal 1, events.size
      assert_equal "webhook_signature_invalid.fuik", events.first[0]
    end

    test "receive_error publishes webhook_receive_error.fuik" do
      events = []

      error = RuntimeError.new("unexpected")

      ActiveSupport::Notifications.subscribed(->(*args) { events << args }, /\.fuik$/) do
        Notifications.receive_error(provider: "stripe", error: error)
      end

      assert_equal 1, events.size
      assert_equal "webhook_receive_error.fuik", events.first[0]
      assert_equal error, events.first[1][:error]
    end
  end
end
