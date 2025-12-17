# frozen_string_literal: true

module Fuik
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_migrations
        rails_command "railties:install:migrations FROM=fuik", inline: true
      end

      def add_route
        route 'mount Fuik::Engine => "/webhooks"'
      end
    end
  end
end
