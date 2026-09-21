# frozen_string_literal: true

Fuik::Engine.routes.draw do
  constraints Fuik::Routing::DashboardConstraint.new do
    root to: "events#index"

    resources :events, only: %w[index show] do
      resources :retries, only: %w[create]
    end
    resources :downloads, only: %w[create]
  end

  post ":provider", to: "webhooks#create", constraints: Fuik::Routing::ProviderConstraint.new
end
