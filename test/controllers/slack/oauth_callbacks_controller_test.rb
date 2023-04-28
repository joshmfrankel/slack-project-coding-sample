# frozen_string_literal: true

require "test_helper"

module Slack
  class OauthCallbacksControllerTest < ActionDispatch::IntegrationTest
    context "GET #new" do
      should "ensure Slack API is called with accurate parameters" do
        slack_client_id = "new_client_id"
        slack_client_secret = "the_secret"
        slack_oauth_redirect_uri = "https://slack.com"
        code = "1234"

        ClimateControl.modify(
          SLACK_CLIENT_ID: slack_client_id,
          SLACK_CLIENT_SECRET: slack_client_secret,
          SLACK_OAUTH_REDIRECT_URI: slack_oauth_redirect_uri
        ) do
          stub_request(:post, "https://slack.com/api/oauth.v2.access").with(
            body: {
              "client_id" => slack_client_id,
              "client_secret" => slack_client_secret,
              "code" => code,
              "redirect_uri" => slack_oauth_redirect_uri
            }
          )

          get slack_oauth_callbacks_path, params: { code: code }
        end
      end
    end
  end
end
