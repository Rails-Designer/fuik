# frozen_string_literal: true

module Fuik
  class Engine < ::Rails::Engine
    isolate_namespace Fuik

    config.webhooks_controller_parent = "ActionController::Base"
    config.events_controller_parent = "ActionController::Base"

    config.to_prepare do
      ActiveSupport.on_load(:action_view) do
        include Fuik::IconHelper
        include Fuik::HighlightHelper
      end
    end
  end
end
