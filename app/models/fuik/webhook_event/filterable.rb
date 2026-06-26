# frozen_string_literal: true

module Fuik
  class WebhookEvent
    module Filterable
      extend ActiveSupport::Concern

      class_methods do
        def filtered(params)
          filters = %w[status provider event_id event_type]

          where(params.permit(*filters).compact_blank.transform_values { it.split(",") })
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
