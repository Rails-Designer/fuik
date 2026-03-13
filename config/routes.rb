# frozen_string_literal: true

Fuik::Engine.routes.draw do
  root to: "events#index"
  resources :events, only: %w[show]
  resources :downloads, only: %w[create]

  post ":provider", to: "webhooks#create"
end
