# frozen_string_literal: true

Fuik::Engine.routes.draw do
  root to: "events#index"

  resources :events, only: %w[index show] do
    resources :retries, only: %w[create]
  end
  resources :downloads, only: %w[create]

  post ":provider", to: "webhooks#create", constraints: Fuik::Routing::ProviderConstraint.new
end
