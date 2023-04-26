# frozen_string_literal: true

require "test_helper"

module Slack
  class CommandsControllerTest < ActionDispatch::IntegrationTest
    context "POST #create" do
      context "when verifying signing secret fails" do
        should "raise Slack::Events::Request::InvalidSignature exception" do
          slack_event_request_mock = mock
          Slack::Events::Request.expects(:new).returns(slack_event_request_mock)
          slack_event_request_mock.expects(:verify!).raises(Slack::Events::Request::InvalidSignature)

          assert_raises Slack::Events::Request::InvalidSignature do
            post slack_commands_path, params: { command: "/rootly", text: "declare title" }
          end
        end
      end

      context "when signing secret is verified" do
        setup do
          slack_event_request_mock = mock
          Slack::Events::Request.expects(:new).returns(slack_event_request_mock)
          slack_event_request_mock.expects(:verify!).returns(true)
        end

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

        context "for `declare` command" do
          should "raises ArgumentError without trigger_id" do
            assert_raises ArgumentError do
              post slack_commands_path, params: { command: "/rootly", text: "declare title", trigger_id: nil }
            end
          end

          should "send API request to open incident modal" do
            stub_request(:post, "https://slack.com/api/views.open")

            post slack_commands_path, params: { command: "/rootly", text: "declare title", trigger_id: 1234 }

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
end
