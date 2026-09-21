require "test_helper"

module Fuik
  module Routing
    class DashboardConstraintTest < ActionDispatch::IntegrationTest
      test "dashboard is reachable by default in development and test" do
        Fuik.configuration.dashboard_enabled = nil

        get "/webhooks"
        assert_response :success

        get "/webhooks/events.json"
        assert_response :success
      end

      test "dashboard is reachable when explicitly enabled" do
        Fuik.configuration.dashboard_enabled = true
        event = create_event(status: "failed")

        get "/webhooks"
        assert_response :success

        get "/webhooks/events/#{event.id}"
        assert_response :success

        get "/webhooks/events/#{event.id}.json"
        assert_response :success

        post "/webhooks/events/#{event.id}/retries"
        assert_redirected_to "/webhooks/events/#{event.id}"
        assert_equal "processed", event.reload.status

        post "/webhooks/downloads", params: {event_id: event.id}
        assert_response :success
      end

      test "dashboard returns 404 when disabled" do
        Fuik.configuration.dashboard_enabled = false
        Fuik.configuration.providers_allowed = []
        event = create_event

        get "/webhooks"
        assert_response :not_found

        get "/webhooks/events.json"
        assert_response :not_found

        get "/webhooks/events/#{event.id}"
        assert_response :not_found

        get "/webhooks/events/#{event.id}.json"
        assert_response :not_found

        post "/webhooks/events/#{event.id}/retries"
        assert_response :not_found

        post "/webhooks/downloads", params: {event_id: event.id}
        assert_response :not_found
      end

      test "dashboard is disabled by default outside development and test" do
        Fuik.configuration.dashboard_enabled = nil

        with_non_local_env do
          get "/webhooks"
          assert_response :not_found
        end
      end

      teardown do
        Fuik.configuration.dashboard_enabled = nil
        Fuik.configuration.providers_allowed = nil
      end

      private

      def create_event(status: "pending")
        WebhookEvent.create!(
          provider: "stripe",
          event_id: "evt_#{SecureRandom.hex(8)}",
          event_type: "checkout.session.completed",
          body: {}.to_json,
          headers: {},
          status: status
        )
      end
    end
  end
end
