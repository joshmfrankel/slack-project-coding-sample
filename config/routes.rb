# frozen_string_literal: true

Rails.application.routes.draw do
  get "/incidents", to: "incidents#index"
  root "incidents#index"

  # Slack endpoints
  post "/slack/commands", to: "slack/commands#create"
  post "/slack/interactions", to: "slack/interactions#create"
  get "/slack/oauths", to: "slack/oauths#new"
  get "/slack/oauth_callbacks", to: "slack/oauth_callbacks#new"

  # Render.com uptime check
  get "/render/health_checks", to: "render/health_checks#index"
end
