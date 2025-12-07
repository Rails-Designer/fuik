module Stripe
  class Base < Fuik::Event
    # Stub implementation for testing
    # Real implementation would use Stripe's HMAC-SHA256 verification
    #
    def self.verify!(request)
      signature = request.headers["Stripe-Signature"]

      raise Fuik::InvalidSignature if signature != "valid_signature"
    end
  end
end
