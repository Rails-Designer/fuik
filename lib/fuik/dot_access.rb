# frozen_string_literal: true

module Fuik
  module DotAccess
    refine Hash do
      def to_dot = AccessPayload.new(self)
    end

    class AccessPayload
      def initialize(payload)
        @payload = payload
      end

      def [](key)
        value = fetch_value(key)

        value.is_a?(Hash) ? self.class.new(value) : value
      end

      def []=(key, value)
        @payload[key] = value
      end

      def dig(*keys)
        value = @payload.dig(*keys)

        value.is_a?(Hash) ? self.class.new(value) : value
      end

      def key?(key)
        @payload.key?(key) || @payload.key?(key.to_s) || @payload.key?(key.to_sym)
      end

      def method_missing(method_name, *arguments)
        return super unless arguments.empty? && !block_given?

        value = fetch_value(method_name)
        value.is_a?(Hash) ? self.class.new(value) : value
      end

      def respond_to_missing?(method_name, include_private = false)
        key?(method_name) || super
      end

      def to_h = @payload

      private

      # Looks the key up as given, as a string, then as a symbol. Checks key?
      # rather than chaining with ||, so a `false` value isn't skipped.
      def fetch_value(key)
        found = [key, key.to_s, key.to_s.to_sym].find { @payload.key?(it) }

        @payload[found] unless found.nil?
      end
    end
  end
end
