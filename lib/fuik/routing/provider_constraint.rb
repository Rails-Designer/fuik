# frozen_string_literal: true

module Fuik
  module Routing
    class ProviderConstraint
      def matches?(request)
        return true if allow_all?
        return explicit_allowlist.include?(request.params[:provider]) if explicit_allowlist?

        return Rails.env.local? if providers_allowed.nil?
        return Rails.env.local? if providers_allowed == true

        scanned_allowlist.include?(request.params[:provider])
      end

      private

      def allow_all? = Fuik::Engine.config.providers_allowed.in?([:all, "all"])

      def explicit_allowlist? = Fuik::Engine.config.providers_allowed.is_a?(Array)

      def explicit_allowlist = Fuik::Engine.config.providers_allowed.to_set

      def providers_allowed = Fuik::Engine.config.providers_allowed

      def scanned_allowlist
        @scanned_allowlist ||= Dir["#{Rails.root}/app/webhooks/*"]
          .select { File.directory?(it) }
          .map { File.basename(it) }
          .to_set
      end
    end
  end
end
