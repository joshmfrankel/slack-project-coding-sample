# frozen_string_literal: true

require "test_helper"

module Slack
  class OauthCallbacksControllerTest < ActionDispatch::IntegrationTest
    context "GET #new" do
      should "return 400 bad request when session state does not match params state" do
        slack_client_id = "new_client_id"
        slack_client_secret = "the_secret"
        slack_oauth_redirect_uri = "https://slack.com"
        code = "1234"
        team_id = "xxxx"
        state = "54321"

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

          # Initiate the session value without stubbing to ensure it doesn't
          # match the incoming params state value
          get slack_oauths_path

          assert_no_difference "SlackTeam.count" do
            get slack_oauth_callbacks_path, params: { code: code, state: state }
          end

          assert_response :bad_request
        end
      end

      should "ensure Slack API is called with accurate parameters" do
        slack_client_id = "new_client_id"
        slack_client_secret = "the_secret"
        slack_oauth_redirect_uri = "https://slack.com"
        code = "1234"
        team_id = "xxxx"
        state = "54321"

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

          # Stub the state value that will be stored in the session
          SecureRandom.stubs(:uuid).returns(state)

          # Initiate the session value
          get slack_oauths_path

          assert_difference "SlackTeam.count" do
            get slack_oauth_callbacks_path, params: { code: code, state: state }
          end

          slack_team = SlackTeam.find_by(external_team_id: team_id)

          assert_equal "my_token", slack_team.access_token
          assert_redirected_to "https://slack.com/app_redirect?channel=general"
        end
      end

      should "refresh access_token for subsequent Oauth attempts for same SlackTeam" do
        slack_client_id = "new_client_id"
        slack_client_secret = "the_secret"
        slack_oauth_redirect_uri = "https://slack.com"
        code = "1234"
        state = "54321"

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

          # Stub the state value that will be stored in the session
          SecureRandom.stubs(:uuid).returns(state)

          # Initiate the session value
          get slack_oauths_path

          assert_no_difference "SlackTeam.count" do
            get slack_oauth_callbacks_path, params: { code: code, state: state }
          end

          slack_team = SlackTeam.find_by(external_team_id: team_id)

          assert_equal "updated_token", slack_team.access_token
          assert_redirected_to "https://slack.com/app_redirect?channel=general"
        end
      end
    end
  end
end
