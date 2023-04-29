# frozen_string_literal: true

require "test_helper"

module Slack
  class OauthsControllerTest < ActionDispatch::IntegrationTest
    context "GET #new" do
      should "ensure redirect is properly formatted with EnvVars" do
        slack_client_id = "client_id"
        slack_app_scopes = "comma,list,of,scope"
        slack_oauth_redirect_uri = "https://slack.com"
        state = "12345"

        ClimateControl.modify(
          SLACK_CLIENT_ID: slack_client_id,
          SLACK_APP_SCOPES: slack_app_scopes,
          SLACK_OAUTH_REDIRECT_URI: slack_oauth_redirect_uri
        ) do
          SecureRandom.stubs(:uuid).returns(state)

          get slack_oauths_path

          assert_redirected_to "https://slack.com/oauth/v2/authorize?client_id=#{slack_client_id}&scope=#{slack_app_scopes}&redirect_uri=#{slack_oauth_redirect_uri}&state=#{state}"
        end
      end
    end
  end
end
