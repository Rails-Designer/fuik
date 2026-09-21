require "test_helper"

module Fuik
  class ConfigurationTest < ActiveSupport::TestCase
    test "provides default webhook_processing_job_class" do
      assert_equal "Fuik::WebhookProcessingJob", Fuik.webhook_processing_job_class
    end

    test "configure sets webhook_processing_job_class" do
      Fuik.configure { it.webhook_processing_job_class = "Custom::Job" }

      assert_equal "Custom::Job", Fuik.webhook_processing_job_class
    ensure
      Fuik.webhook_processing_job_class = "Fuik::WebhookProcessingJob"
    end

    test "dashboard_enabled? defaults to development and test environments" do
      Fuik.configuration.dashboard_enabled = nil

      assert_equal Rails.env.development? || Rails.env.test?, Fuik.configuration.dashboard_enabled?
    end

    test "dashboard_enabled? can be overridden to true" do
      Fuik.configuration.dashboard_enabled = true

      assert Fuik.configuration.dashboard_enabled?
    ensure
      Fuik.configuration.dashboard_enabled = nil
    end

    test "dashboard_enabled? can be overridden to false" do
      Fuik.configuration.dashboard_enabled = false

      refute Fuik.configuration.dashboard_enabled?
    ensure
      Fuik.configuration.dashboard_enabled = nil
    end
  end
end
