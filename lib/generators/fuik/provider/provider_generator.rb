# frozen_string_literal: true

module Fuik
  module Generators
    class ProviderGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)
      desc "Generate webhook provider base class and event classes"

      argument :event_names, type: :array, default: []

      def create_base_class
        template "base.rb.tt", "app/webhooks/#{file_name}/base.rb"
      end

      def create_event_classes
        event_names.each do |event_name|
          @event_name = event_name

          if packaged_event_exists?
            copy_packaged_event
          else
            create_blank_event
          end
        end
      end

      private

      def packaged_event_exists? = File.exist?(packaged_event_template_path)

      def copy_packaged_event
        template packaged_event_template_path, event_file_path
      end

      def create_blank_event
        template "event.rb.tt", event_file_path
      end

      def packaged_event_template_path = File.join(self.class.source_root, "providers", file_name, "#{event_file_name}.rb.tt")

      def event_file_path = Rails.join("app", "webhooks", file_name, "#{event_file_name}.rb")

      def event_file_name = @event_name.underscore

      def event_class_name = @event_name.camelize

      def provider_module_name = file_name.camelize
    end
  end
end
