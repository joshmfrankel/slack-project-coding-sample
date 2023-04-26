# frozen_string_literal: true

require "test_helper"

module Slack
  class InteractionsControllerTest < ActionDispatch::IntegrationTest
    context "POST #create" do
      context "when verifying signing secret fails" do
        should "raise Slack::Events::Request::InvalidSignature exception" do
          slack_event_request_mock = mock
          Slack::Events::Request.expects(:new).returns(slack_event_request_mock)
          slack_event_request_mock.expects(:verify!).raises(Slack::Events::Request::InvalidSignature)

          assert_raises Slack::Events::Request::InvalidSignature do
            post slack_interactions_path
          end
        end
      end

      context "when signing secret is verified" do
        setup do
          slack_event_request_mock = mock
          Slack::Events::Request.expects(:new).returns(slack_event_request_mock)
          slack_event_request_mock.expects(:verify!).returns(true)
        end

        context "without payload" do
          should "return error message" do
            post slack_interactions_path, params: { payload: nil }

            json_response = JSON.parse(response.body)

            assert_equal json_response, {
              "blocks" => [
                {
                  "type" => "section",
                  "text" => {
                    "type" => "plain_text",
                    "text" => "There was a problem communicating with Slack. Please try again later."
                  }
                }
              ]
            }
          end
        end

        context "with valid payload" do
          should "parses payload, sends messages to Slack API, and persists to Incident model" do
            payload_json = {
              user: {
                id: "XHDI12AH"
              },
              view: {
                state: {
                  # Value keys are string keys based on internal slack implementation
                  values: {
                    a: {
                      title_input: {
                        type: "plain_text_input",
                        value: "My first incident"
                      }
                    },
                    b: {
                      description_input: {
                        type: "plain_text_input",
                        value: "A detailed description of the incident"
                      }
                    },
                    c: {
                      severity_selection: {
                        type: "static_select",
                        value: "sev1"
                      }
                    }
                  }
                }
              }
            }.to_json

            channel_id = 123
            stubbed_channel_result = {
              ok: true,
              channel: {
                id: channel_id
              }
            }.to_json
            stub_request(:post, "https://slack.com/api/conversations.create")
              .with(
                body: {
                  name: /my-first-incident-(\d+)/ # Regex allows for ensuring that future channel names in test setup always work
                }
              ).to_return(body: stubbed_channel_result)
            stub_request(:post, "https://slack.com/api/conversations.join")
              .with(
                body: {
                  channel: channel_id
                }
              )

            assert_difference "Incident.count" do
              post slack_interactions_path, params: {
                payload: payload_json
              }
            end

            assert_response :success
          end
        end
      end
    end
  end
end
