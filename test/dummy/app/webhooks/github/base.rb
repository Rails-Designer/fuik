module Github
  class Base < Fuik::Event
    event_type header: "X-Github-Event"
    event_id header: "X-GitHub-Delivery"
  end
end
