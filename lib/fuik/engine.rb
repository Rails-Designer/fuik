# frozen_string_literal: true

require "fuik/routing/provider_constraint"
require "fuik/routing/dashboard_constraint"

module Fuik
  class Engine < ::Rails::Engine
    isolate_namespace Fuik

    config.to_prepare do
      ActiveSupport.on_load(:action_view) do
        include Fuik::IconHelper
        include Fuik::HighlightHelper
      end
    end
  end
end
