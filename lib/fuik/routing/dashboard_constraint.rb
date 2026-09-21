# frozen_string_literal: true

module Fuik
  module Routing
    class DashboardConstraint
      def matches?(request) = Fuik.configuration.dashboard_enabled?
    end
  end
end
