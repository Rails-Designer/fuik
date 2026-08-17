require "fuik/version"
require "fuik/dot_access"
require "fuik/configuration"
require "fuik/notifications"
require "fuik/engine"

module Fuik
  class InvalidSignature < StandardError; end

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("1.0", "Fuik")
  end
end
