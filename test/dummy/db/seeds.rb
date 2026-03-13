require "json"

puts "Clearing existing webhook events…"
Fuik::WebhookEvent.delete_all

puts "Loading seed data…"
seeds_path = Rails.root.join("../../bin/seed_data/events.json")
events = JSON.parse(File.read(seeds_path))

events.each_with_index do |event, index|
  Fuik::WebhookEvent.create!(
    provider: event["provider"],
    event_id: event["event_id"],
    event_type: event["event_type"],
    body: event["body"],
    headers: event["headers"],
    status: event["status"],
    error: event["error"],
    created_at: Time.now - (index * 3600)
  )
end

puts "Created #{events.length} webhook events"
