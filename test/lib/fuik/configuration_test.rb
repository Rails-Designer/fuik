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
  end
end
