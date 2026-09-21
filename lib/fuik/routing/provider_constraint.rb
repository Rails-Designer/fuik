# frozen_string_literal: true

module Fuik
  module Routing
    class ProviderConstraint
      def matches?(request)
        return true if allow_all?
        return explicit_allowlist.include?(request.params[:provider]) if explicit_allowlist?

        false
      end

      private

      def allow_all? = providers_allowed.nil? || providers_allowed == true || providers_allowed.in?([:all, "all"])

      def explicit_allowlist? = providers_allowed.is_a?(Array)

      def explicit_allowlist = providers_allowed.to_set

      def providers_allowed = Fuik.configuration.providers_allowed
    end
  end
end
