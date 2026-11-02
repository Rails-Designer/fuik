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
        value = keys.reduce(self) do |current, key|
          case current
          when nil then return nil
          when AccessPayload then current[key]
          when Hash then self.class.new(current)[key]
          when Array then current[key]
          else raise TypeError, "#{current.class} does not have #dig method"
          end
        end

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

      def fetch_value(key)
        found = [key, key.to_s, key.to_s.to_sym].find { @payload.key?(it) }

        @payload[found] unless found.nil?
      end
    end
  end
end
