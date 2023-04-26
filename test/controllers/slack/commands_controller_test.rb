# frozen_string_literal: true

require "test_helper"

module Slack
  class CommandsControllerTest < ActionDispatch::IntegrationTest
    context "POST #create" do
      context "with invalid payload text" do
        should "return error message with `nil` text" do
          post slack_commands_path, params: { command: "/rootly", text: nil }

          json_response = JSON.parse(response.body)

          assert_equal json_response, {
            "blocks" => [
              {
                "type" => "section",
                "text" => {
                  "type" => "plain_text",
                  "text" => "We're sorry. This command wasn't recognized."
                }
              }
            ]
          }
        end

        should "return error message with unrecognized text" do
          post slack_commands_path, params: { command: "/rootly", text: "invalid" }

          json_response = JSON.parse(response.body)

          assert_equal json_response, {
            "blocks" => [
              {
                "type" => "section",
                "text" => {
                  "type" => "plain_text",
                  "text" => "We're sorry. This command wasn't recognized."
                }
              }
            ]
          }
        end
      end

      #pending "secret signature check"

      context "for `declare` command" do
        should "return 200 success" do
          post slack_commands_path, params: { command: "/rootly", text: "declare title" }

          assert_response :success
        end
      end

      context "for `help` command" do
        should "return immediate building blocks message" do
          post slack_commands_path, params: { command: "/rootly", text: "help" }

          json_response = JSON.parse(response.body)

          assert_equal json_response, {
            "blocks" => [
              {
                "type" => "section",
                "text" => {
                  "type" => "mrkdwn",
                  "text" => "Rootly Commands\n\n* `/rootly declare <title>` - Create a new incident\n* `/rootly resolve` - Resolve an incident from a channel\n* `/rootly help` - Display help options"
                }
              }
            ]
          }
        end
      end
    end
  end
end
