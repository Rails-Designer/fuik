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
        value = @payload[key] || @payload[key.to_s] || @payload[key.to_sym]

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

        value = @payload[method_name] || @payload[method_name.to_s] || @payload[method_name.to_sym]
        value.is_a?(Hash) ? self.class.new(value) : value
      end

      def respond_to_missing?(method_name, include_private = false)
        key?(method_name) || super
      end

      def to_h = @payload
    end
  end
end
