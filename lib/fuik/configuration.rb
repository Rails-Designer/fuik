# frozen_string_literal: true

module Fuik
  mattr_accessor :webhook_processing_job_class, default: "Fuik::WebhookProcessingJob"

  def self.configure
    yield self
  end
end
