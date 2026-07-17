module Chirpform
  class Base < Fuik::Event
    event_type header: "X-Chirpform-Event"
    event_id header: "X-Chirpform-Id"
  end
end
