require "test_helper"

module Fuik
  module Routing
    class ProviderConstraintTest < ActionDispatch::IntegrationTest
      test "allows all providers when config is :all" do
        Fuik::Engine.config.providers_allowed = :all

        post "/webhooks/anything",
          params: { id: "evt_123" }.to_json,
          headers: { "Content-Type" => "application/json" }

        assert_response :ok
      end

      test "allows all providers when config is 'all'" do
        Fuik::Engine.config.providers_allowed = "all"

        post "/webhooks/anything",
          params: { id: "evt_123" }.to_json,
          headers: { "Content-Type" => "application/json" }

        assert_response :ok
      end

      test "allows providers from explicit array" do
        Fuik::Engine.config.providers_allowed = %w[stripe chirpform]

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

      test "defaults to allow all in local environment" do
        Fuik::Engine.config.providers_allowed = nil

        post "/webhooks/any_provider",
          params: { id: "evt_123" }.to_json,
          headers: { "Content-Type" => "application/json" }

        assert_response :ok
      end

      teardown do
        Fuik::Engine.config.providers_allowed = nil
      end
    end
  end
end
