# frozen_string_literal: true

module Fuik
  module IconHelper
    def icon(provider)
      provider = provider.to_s.downcase
      path = "fuik/icons/#{provider}.jpg"

      if asset_exists?(path)
        image_tag path, alt: provider.capitalize, class: "icon"
      else
        image_tag "fuik/icons/webhook.svg", alt: "Webhook", class: "icon"
      end
    end

    private

    def asset_exists?(path)
      if defined?(Propshaft)
        Rails.application.assets.load_path.find(path).present?
      else
        Rails.application.assets&.find_asset(path).present?
      end
    rescue
      false
    end
  end
end
