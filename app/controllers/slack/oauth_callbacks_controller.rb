# frozen_string_literal: true

module Slack
  # Exchange temporary Oauth code for access token in Slack workspace
  # @see https://api.slack.com/authentication/oauth-v2#exchanging
  # @see https://api.slack.com/methods/oauth.v2.access
  class OauthCallbacksController < ApplicationController
    def new
      client = Slack::Web::Client.new
      result = client.oauth_v2_access(
        code: params[:code],
        client_id: ENV["SLACK_CLIENT_ID"],
        client_secret: ENV["SLACK_CLIENT_SECRET"],
        redirect_uri: ENV["SLACK_OAUTH_REDIRECT_URI"]
      )

      if result[:ok] == true
        slack_team = SlackTeam.new(access_token: result[:access_token], external_team_id: result[:team][:id])

        if slack_team.save
          head :ok
        else
          head 500
        end
      else
        head 500
      end
    end
  end
end
