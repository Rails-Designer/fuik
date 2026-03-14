require "test_helper"

module Fuik
  class DotAccessTest < ActiveSupport::TestCase
    using DotAccess

    def setup
      @payload = {
        "id" => "evt_123",
        "type" => "checkout.session.completed",
        "data" => {
          "object" => {
            "client_reference_id" => "user_456",
            "metadata" => { "plan" => "premium" }
          }
        }
      }.to_dot
    end

    test "provides dot notation access to top-level keys" do
      assert_equal "evt_123", @payload.id
      assert_equal "checkout.session.completed", @payload.type
    end

    test "provides hash syntax access" do
      assert_equal "evt_123", @payload["id"]
      assert_equal "checkout.session.completed", @payload["type"]
    end

    test "supports dig method" do
      assert_equal "user_456", @payload.dig("data", "object", "client_reference_id")
      assert_equal "premium", @payload.dig("data", "object", "metadata", "plan")
    end

    test "supports nested dot notation access" do
      assert_equal "user_456", @payload.data.object.client_reference_id
      assert_equal "premium", @payload.data.object.metadata.plan
    end

    test "supports mixed access patterns" do
      assert_equal "premium", @payload["data"].object.metadata["plan"]
      assert_equal "user_456", @payload.data["object"].client_reference_id
    end

    test "supports symbol key access" do
      payload_with_symbols = { id: "evt_456", customer: { name: "John" } }.to_dot

      assert_equal "evt_456", payload_with_symbols[:id]
      assert_equal "John", payload_with_symbols[:customer][:name]

      assert_equal "evt_123", @payload[:id]  # string key accessed with symbol
      assert_equal "John", payload_with_symbols.dig(:customer, :name)
    end

    test "supports key? method" do
      assert @payload.key?("id")
      assert @payload.key?("type")

      refute @payload.key?("nonexistent")
    end

    test "returns original hash with to_h" do
      original = { "test" => "value" }
      dot_payload = original.to_dot

      assert_equal original, dot_payload.to_h
    end

    test "handles assignment" do
      @payload["new_key"] = "new_value"

      assert_equal "new_value", @payload.new_key
      assert_equal "new_value", @payload["new_key"]
    end
  end
end
