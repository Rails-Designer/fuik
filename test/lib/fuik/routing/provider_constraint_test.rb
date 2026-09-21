require "test_helper"

module Fuik
  module Routing
    class ProviderConstraintTest < ActionDispatch::IntegrationTest
      test "allows all providers when config is :all" do
        Fuik.configuration.providers_allowed = :all

        post "/webhooks/anything",
          params: { id: "evt_123" }.to_json,
          headers: { "Content-Type" => "application/json" }

        assert_response :ok
      end

      test "allows all providers when config is 'all'" do
        Fuik.configuration.providers_allowed = "all"

        post "/webhooks/anything",
          params: { id: "evt_123" }.to_json,
          headers: { "Content-Type" => "application/json" }

        assert_response :ok
      end

      test "allows providers from explicit array" do
        Fuik.configuration.providers_allowed = %w[stripe chirpform]

        post "/webhooks/stripe",
          params: { id: "evt_1", type: "checkout.session.completed" }.to_json,
          headers: { "Content-Type" => "application/json", "Stripe-Signature" => "valid_signature" }
        assert_response :ok

        post "/webhooks/chirpform",
          params: { id: "evt_2" }.to_json,
          headers: { "Content-Type" => "application/json" }
        assert_response :ok

        post "/webhooks/unknown",
          params: { id: "evt_3" }.to_json,
          headers: { "Content-Type" => "application/json" }
        assert_response :not_found
      end

      test "allows all providers by default" do
        Fuik.configuration.providers_allowed = nil

        post "/webhooks/any_provider",
          params: { id: "evt_123" }.to_json,
          headers: { "Content-Type" => "application/json" }

        assert_response :ok
      end

      test "allows all providers by default outside development and test" do
        Fuik.configuration.providers_allowed = nil

        with_non_local_env do
          post "/webhooks/any_provider",
            params: { id: "evt_123" }.to_json,
            headers: { "Content-Type" => "application/json" }

          assert_response :ok
        end
      end

      teardown do
        Fuik.configuration.providers_allowed = nil
      end
    end
  end
end
