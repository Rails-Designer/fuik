# frozen_string_literal: true

module Fuik
  class WebhookEvent
    module Filterable
      extend ActiveSupport::Concern

      class_methods do
        def filtered(params)
          records = all
          records = records.where(status: params[:status]) if params[:status].present?
          records = records.where(provider: params[:provider]) if params[:provider].present?
          records
        end

        def options_for_select
          by_provider_name.pluck(:provider).map { [it.humanize, it] }
        end
      end

      included do
        scope :by_provider_name, -> { distinct.order(:provider) }
      end
    end
  end
end
