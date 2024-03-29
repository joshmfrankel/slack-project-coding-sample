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

        context "with invalid payload" do
          should "return error message when payload missing" do
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

          should "log a server message and respond with no_content when the callback_id is unknown" do
            slack_team_mock = mock
            SlackTeam
              .expects(:find_by)
              .with(external_team_id: "T09125712")
              .returns(slack_team_mock)

            payload_json = {
              view: {
                callback_id: "unknown"
              },
              team: {
                id: "T09125712"
              }
            }.to_json

            post slack_interactions_path, params: { payload: payload_json }

            assert_response :no_content
          end
        end

        context "with valid payload" do
          context "when CreateIncidentService encounters a failure" do
            should "update modal for ActiveRecord validation errors" do
              slack_team_mock = mock
              SlackTeam
                .expects(:find_by)
                .with(external_team_id: "T09125712")
                .returns(slack_team_mock)
              slack_team_mock.expects(:access_token).returns("token_string")

              payload_json = {
                user: {
                  id: "XHDI12AH",
                  name: "Jane User"
                },
                team: {
                  id: "T09125712"
                },
                view: {
                  callback_id: Slack::Constants::CREATE_INCIDENT_MODAL_CALLBACK_ID,
                  state: {
                    # Value keys are string keys based on internal slack implementation
                    values: {
                      a: {
                        title_input: {
                          type: "plain_text_input",
                          value: nil # Incidents are invalid without a title
                        }
                      }
                    }
                  }
                }
              }.to_json

              post slack_interactions_path, params: {
                payload: payload_json
              }

              json_response = JSON.parse(response.body)

              assert_equal json_response, {
                "response_action" => "update",
                "view" => {
                  "type" => "modal",
                  "title" => {
                    "type" => "plain_text",
                    "text" => "Error encountered"
                  },
                  "blocks" => [
                    {
                      "type" => "section",
                      "text" => {
                        "type" => "plain_text",
                        "text" => "Title can't be blank"
                      }
                    }
                  ]
                }
              }
            end

            should "update modal for Slack api service errors" do
              slack_team_mock = mock
              SlackTeam
                .expects(:find_by)
                .with(external_team_id: "T09125712")
                .returns(slack_team_mock)
              slack_team_mock.expects(:access_token).returns("token_string")

              payload_json = {
                user: {
                  id: "XHDI12AH",
                  name: "Jane User"
                },
                team: {
                  id: "T09125712"
                },
                view: {
                  callback_id: Slack::Constants::CREATE_INCIDENT_MODAL_CALLBACK_ID,
                  state: {
                    # Value keys are string keys based on internal slack implementation
                    values: {
                      a: {
                        title_input: {
                          type: "plain_text_input",
                          value: "A title"
                        }
                      }
                    }
                  }
                }
              }.to_json

              mock_service = mock
              CreateIncidentService.expects(:new).returns(mock_service)
              mock_service.expects(:call).returns(
                Failure([:failed_to_create_channel, "Channel could not be created. Please try again later."])
              )

              post slack_interactions_path, params: {
                payload: payload_json
              }

              json_response = JSON.parse(response.body)

              assert_equal json_response, {
                "response_action" => "update",
                "view" => {
                  "type" => "modal",
                  "title" => {
                    "type" => "plain_text",
                    "text" => "Error encountered"
                  },
                  "blocks" => [
                    {
                      "type" => "section",
                      "text" => {
                        "type" => "plain_text",
                        "text" => "Channel could not be created. Please try again later."
                      }
                    }
                  ]
                }
              }
            end
          end

          context "when CreateIncidentService is successful" do
            should "parses payload, sends messages to Slack API, and persists to Incident model" do
              team_id = "T09125712"
              user_id = "XHDI12AH"
              user_name = "Jane User"
              SlackTeam.create(external_team_id: team_id, access_token: "string_token")
              payload_json = {
                user: {
                  id: user_id,
                  name: user_name
                },
                team: {
                  id: team_id
                },
                view: {
                  callback_id: Slack::Constants::CREATE_INCIDENT_MODAL_CALLBACK_ID,
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
                          selected_option: {
                            value: "sev1"
                          }
                        }
                      }
                    }
                  }
                }
              }.to_json

              channel_id = 123
              stubbed_create_channel_result = {
                ok: true,
                channel: {
                  id: channel_id
                }
              }.to_json
              stub_request(:post, "https://slack.com/api/conversations.create")
                .with(
                  body: {
                    # Regex allows for ensuring that future channel names in test setup always work
                    name: /(\d+)-my-first-incident/
                  }
                ).to_return(body: stubbed_create_channel_result)

              stubbed_post_message_result = {
                ok: true
              }.to_json
              stub_request(:post, "https://slack.com/api/chat.postMessage")
                .to_return(body: stubbed_post_message_result)

              assert_difference "Incident.count" do
                post slack_interactions_path, params: {
                  payload: payload_json
                }
              end

              incident_exists = Incident.exists?(external_slack_user_id: user_id, external_slack_user_name: user_name)

              assert incident_exists

              assert_response :success
            end
          end
        end
      end
    end
  end
end
