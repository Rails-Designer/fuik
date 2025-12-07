require "test_helper"

module Fuik
  class WebhooksControllerTest < ActionDispatch::IntegrationTest
    test "creates webhook event with valid JSON payload" do
      assert_difference "WebhookEvent.count", 1 do
        post "/webhooks/stripe",
          params: { id: "evt_123", type: "checkout.session.completed", data: { amount: 5000 } }.to_json,
          headers: { "Content-Type" => "application/json", "Stripe-Signature" => "valid_signature" }
      end

      assert_response :ok

      event = WebhookEvent.last
      assert_equal "stripe", event.provider
      assert_equal "evt_123", event.event_id
      assert_equal "checkout.session.completed", event.event_type
      assert_equal "processed", event.status
      assert_equal({ "id" => "evt_123", "type" => "checkout.session.completed", "data" => { "amount" => 5000 } }, event.payload)
    end

    test "handles idempotency - duplicate event_id returns 200 without creating" do
      post "/webhooks/stripe",
        params: { id: "evt_123", type: "test" }.to_json,
        headers: { "Content-Type" => "application/json", "Stripe-Signature" => "valid_signature" }

      assert_response :ok

      assert_no_difference "WebhookEvent.count" do
        post "/webhooks/stripe",
          params: { id: "evt_123", type: "test" }.to_json,
          headers: { "Content-Type" => "application/json", "Stripe-Signature" => "valid_signature" }
      end

      assert_response :ok
    end

    test "extracts event_id from payload or falls back to MD5 hash" do
      post "/webhooks/github",
        params: { id: "custom_id", action: "opened" }.to_json,
        headers: { "Content-Type" => "application/json" }

      assert_equal "custom_id", WebhookEvent.last.event_id

      body = { action: "closed", number: 42 }.to_json
      post "/webhooks/github",
        params: body,
        headers: { "Content-Type" => "application/json" }

      assert_equal Digest::MD5.hexdigest(body), WebhookEvent.last.event_id
    end

    test "extracts event_id from GitHub headers" do
      post "/webhooks/github",
        params: { action: "opened" }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "X-GitHub-Delivery" => "12345-67890-abcdef"
        }

      assert_equal "12345-67890-abcdef", WebhookEvent.last.event_id
    end

    test "extracts event_type from common payload fields" do
      post "/webhooks/stripe",
        params: { id: "1", type: "payment.succeeded" }.to_json,
        headers: { "Content-Type" => "application/json", "Stripe-Signature" => "valid_signature" }
      assert_equal "payment.succeeded", WebhookEvent.last.event_type

      post "/webhooks/github",
        params: { id: "2", event: "push" }.to_json,
        headers: { "Content-Type" => "application/json" }
      assert_equal "push", WebhookEvent.last.event_type

      post "/webhooks/custom",
        params: { id: "3", event_type: "user.created" }.to_json,
        headers: { "Content-Type" => "application/json" }
      assert_equal "user.created", WebhookEvent.last.event_type

      post "/webhooks/unknown",
        params: { id: "4", data: "test" }.to_json,
        headers: { "Content-Type" => "application/json" }
      assert_equal "unknown", WebhookEvent.last.event_type
    end

    test "extracts event_type from GitHub headers" do
      post "/webhooks/github",
        params: { id: "5", action: "opened" }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "X-GitHub-Event" => "pull_request"
        }

      assert_equal "pull_request", WebhookEvent.last.event_type
    end

    test "uses config for custom event_type and event_id lookup" do
      post "/webhooks/chirpform",
        params: { custom_data: "test" }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "X-Chirpform-Event" => "form.submitted",
          "X-Chirpform-Id" => "cf_12345"
        }

      event = WebhookEvent.last
      assert_equal "form.submitted", event.event_type
      assert_equal "cf_12345", event.event_id
    end

    test "captures HTTP headers" do
      post "/webhooks/stripe",
        params: { id: "evt_123", type: "test" }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "User-Agent" => "TestAgent/1.0",
          "Stripe-Signature" => "valid_signature"
        }

      event = WebhookEvent.last
      assert_equal "application/json", event.headers["Content-Type"]
      assert_equal "TestAgent/1.0", event.headers["User-Agent"]
    end

    test "verifies signature when Base class implements verify!" do
      post "/webhooks/stripe",
        params: { id: "evt_999", type: "test" }.to_json,
        headers: {
          "Content-Type" => "application/json",
          "Stripe-Signature" => "valid_signature"
        }

      assert_response :ok
      assert_equal "stripe", WebhookEvent.last.provider
    end

    test "rejects webhook with invalid signature" do
      assert_no_difference "WebhookEvent.count" do
        post "/webhooks/stripe",
          params: { id: "evt_invalid", type: "checkout.session.completed" }.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Stripe-Signature" => "invalid_signature"
          }
      end

      assert_response :unauthorized
    end

    test "skips verification when no Base class exists" do
      post "/webhooks/unknown_provider",
        params: { id: "evt_123", type: "test" }.to_json,
        headers: { "Content-Type" => "application/json" }

      assert_response :ok
    end
  end
end
