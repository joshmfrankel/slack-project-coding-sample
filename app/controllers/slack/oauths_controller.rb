# frozen_string_literal: true

module Slack
  # Perform app authorization request
  # @see https://api.slack.com/authentication/oauth-v2#asking
  class OauthsController < ApplicationController
    def new
      session[:state] = SecureRandom.uuid
      redirect_to("https://slack.com/oauth/v2/authorize?client_id=#{ENV["SLACK_CLIENT_ID"]}&scope=#{ENV["SLACK_APP_SCOPES"]}&redirect_uri=#{ENV["SLACK_OAUTH_REDIRECT_URI"]}&state=#{session[:state]}", allow_other_host: true)
    end
  end
end
