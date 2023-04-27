# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post "/slack/commands", to: "slack/commands#create"
  post "/slack/interactions", to: "slack/interactions#create"

  # Render.com uptime check
  get "/render/health_checks", to: "render/health_checks#index"
end
