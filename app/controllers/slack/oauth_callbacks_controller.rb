# frozen_string_literal: true

module Slack
  # Exchange temporary Oauth code for access token in Slack workspace
  # @see https://api.slack.com/authentication/oauth-v2#exchanging
  # @see https://api.slack.com/methods/oauth.v2.access
  class OauthCallbacksController < ApplicationController
    def new
      client = Slack::Web::Client.new
      client.oauth_v2_access(
        code: params[:code],
        client_id: ENV["SLACK_CLIENT_ID"],
        client_secret: ENV["SLACK_CLIENT_SECRET"],
        redirect_uri: ENV["SLACK_OAUTH_REDIRECT_URI"]
      )

      head :ok
    end
  end
end
