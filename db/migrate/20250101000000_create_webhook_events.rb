# frozen_string_literal: true

class CreateWebhookEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :fuik_webhook_events do |t|
      t.string :provider, null: false
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.text :body, null: false
      t.json :headers, default: {}, null: false
      t.string :status, default: "pending", null: false
      t.text :error, null: true

      t.timestamps
    end

    add_index :fuik_webhook_events, [:provider, :event_id], unique: true
    add_index :fuik_webhook_events, :status
    add_index :fuik_webhook_events, :created_at
    add_index :fuik_webhook_events, [:provider, :event_type]
  end
end
