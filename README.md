# Fuik

**A fish trap for webhooks**

Fuik (Dutch for fish trap) is a Rails engine that catches and stores webhooks from any provider. View all events in the admin interface, then create event classes to add your business logic.

<img alt="Fuik admin interface" src="https://raw.githubusercontent.com/Rails-Designer/fuik/HEAD/.github/docs/webhooks-index.jpg" style="max-width: 100%;">


**Sponsored By [Rails Designer](https://railsdesigner.com/)**

<a href="https://railsdesigner.com/" target="_blank">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Rails-Designer/fuik/HEAD/.github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Rails-Designer/fuik/HEAD/.github/logo-light.svg">
    <img alt="Rails Designer" src="https://raw.githubusercontent.com/Rails-Designer/fuik/HEAD/.github/logo-light.svg" width="240" style="max-width: 100%;">
  </picture>
</a>


## Quick start

```bash
# Install
bundle add fuik
bin/rails generate fuik:install
bin/rails db:migrate

# Point your webhook to
POST https://yourdomain.com/webhooks/stripe
```

That's it. Webhooks are captured and visible at `/webhooks`.


## Installation

Add to your Gemfile:
```ruby
gem "fuik"
```

Then run:
```bash
bundle install
bin/rails generate fuik:install
bin/rails db:migrate
```

The engine mounts at `/webhooks` automatically.


## Usage

### View events

Visit `/webhooks` to see all received webhooks. Click any event to view all the payload details and copy the payload or download as JSON.

<img alt="Fuik event detail interface" src="https://raw.githubusercontent.com/Rails-Designer/fuik/HEAD/.github/docs/event-detail.jpg" style="max-width: 100%;">

⚠️ The `/webhooks` path is by default not protected. Easiest is to set `Fuik::Engine.config.events_controller_parent` to a controller that requires authentication.


### Add business logic

Generate classes for events you want to process:
```bash
bin/rails generate fuik:provider stripe checkout_session_completed
```

This creates:
- `app/webhooks/stripe/base.rb`
- `app/webhooks/stripe/checkout_session_completed.rb`

Each class is a thin wrapper around your business logic:
```ruby
module Stripe
  class CheckoutSessionCompleted < Base
    def process!
      User.find_by(id: payload.client_reference_id).tap do |user|
        user.activate_subscription!
        user.send_welcome_email

        # etc.
      end

      @webhook_event.processed!
    end
  end
end
```

The `payload` method supports dot notation and standard hash methods:
```ruby
# Dot notation
payload.client_reference_id
payload.customer.email

# Hash syntax (strings/symbols)
payload["client_reference_id"]
payload[:customer_id]
```

Implement `Base.verify!` to enable signature verification:
```ruby
module Stripe
  class Base < Fuik::Event
    def self.verify!(request)
      secret = Rails.application.credentials.dig(:stripe, :signing_secret)
      signature = request.headers["Stripe-Signature"]

      Stripe::Webhook.construct_event(
        request.raw_post,
        signature,
        secret
      )
    rescue Stripe::SignatureVerificationError => error
      raise Fuik::InvalidSignature, error.message
    end
  end
end
```

If `Provider::Base.verify!` exists, Fuik calls it automatically. Invalid signatures return 401 without storing the webhook.


### Provider allowlist

By default:
- **Development/test**: all providers are allowed
- **Production/staging**: only providers in `app/webhooks/` are allowed

Configure with `Fuik::Engine.config.providers_allowed`:
```ruby
# Allow all (including production)
Fuik::Engine.config.providers_allowed = :all

# Explicit allowlist (overrides directory scan)
Fuik::Engine.config.providers_allowed = %w[stripe github shopify]
```

Unknown providers return `404 Not Found`.


### Pre-packaged providers

Fuik includes ready-to-use [templates for common providers](https://github.com/Rails-Designer/fuik/tree/main/lib/generators/fuik/provider/templates).


### Event type & ID lookup

Fuik automatically extracts event types and IDs from common locations:

**Event Type:**
1. provider config (if exists);
2. common headers (`X-Github-Event`, `X-Event-Type`, etc.);
3. payload (`type`, `event`, `event_type`);
4. falls back to `"unknown"`.

**Event ID:**
1. provider config (if exists);
2. common headers (`X-GitHub-Delivery`, `X-Event-Id`, etc.);
3. payload (`id`).
4. falls back to MD5 hash of request body.


#### Custom lookup via config

Create `app/webhooks/provider_name/config.yml`:
```yaml
event_type:
  source: header
  key: X-Custom-Event

event_id:
  source: payload
  key: custom_id
```

The options for `event_type`'s source are:

- header
- payload
- static; for cases when no event type is present in header or payload


## Add your custom provider

Have a provider template others could use? Add it to [lib/generators/fuik/provider/templates/your_provider/](https://github.com/Rails-Designer/fuik/tree/main/lib/generators/fuik/provider/templates) and submit a PR!

Include:
- `base.rb.tt` with signature verification (if applicable);
- event class templates with helpful TODO comments.


## Contributing

This project uses [Standard](https://github.com/testdouble/standard) for formatting Ruby code. Please make sure to run `rake` before submitting pull requests.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
