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
        team_id = "xxxx"

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
          ).to_return(
            body: {
              ok: true,
              access_token: "my_token",
              team: {
                id: team_id
              }
            }.to_json
          )

          assert_difference "SlackTeam.count" do
            get slack_oauth_callbacks_path, params: { code: code }
          end

          slack_team = SlackTeam.find_by(external_team_id: team_id)

          assert_equal "my_token", slack_team.access_token
        end
      end

      should "refresh access_token for subsequent Oauth attempts for same SlackTeam" do
        slack_client_id = "new_client_id"
        slack_client_secret = "the_secret"
        slack_oauth_redirect_uri = "https://slack.com"
        code = "1234"

        team_id = "xxxx"
        SlackTeam.create(external_team_id: team_id, access_token: "string_token")

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
          ).to_return(
            body: {
              ok: true,
              access_token: "updated_token",
              team: {
                id: team_id
              }
            }.to_json
          )

          assert_no_difference "SlackTeam.count" do
            get slack_oauth_callbacks_path, params: { code: code }
          end

          slack_team = SlackTeam.find_by(external_team_id: team_id)

          assert_equal "updated_token", slack_team.access_token
        end
      end
    end
  end
end
