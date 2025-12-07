# frozen_string_literal: true

module Fuik
  class Engine < ::Rails::Engine
    isolate_namespace Fuik

    config.webhooks_controller_parent = "ActionController::Base"
    config.events_controller_parent = "ActionController::Base"
  end
end
