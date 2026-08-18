# frozen_string_literal: true

require "fuik/version"
require "fuik/errors"
require "fuik/configuration"
require "fuik/dot_access"
require "fuik/notifications"
require "fuik/engine"

module Fuik
  class InvalidSignature < StandardError; end

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("1.0", "Fuik")
  end
end
