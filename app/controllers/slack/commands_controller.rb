# frozen_string_literal: true

module Slack
  # Entry point for all `/rootly` Slack Slash commands
  class CommandsController < ApplicationController
    include Slack::VerifyRequestSignature
    include Slack::Constants
    include ActionView::Helpers::DateHelper

    skip_before_action :verify_authenticity_token

    # @see https://www.rubydoc.info/docs/rails/3.2.8/ActionView/Helpers/DateHelper:distance_of_time_in_words
    def create
      return json_error_response unless params[:text].present?
      text_command, text_payload = params[:text].split(" ", 2)

      case text_command
      when "declare"
        client = Slack::Web::Client.new
        client.views_open(
          trigger_id: params[:trigger_id],
          view: {
            type: "modal",
            callback_id: CREATE_INCIDENT_MODAL_CALLBACK_ID,
            title: {
              type: "plain_text",
              text: I18n.t("slack.commands.create.modal.title")
            },
            submit: {
              type: "plain_text",
              text: I18n.t("slack.commands.create.modal.submit")
            },
            blocks: [
              {
                type: "input",
                element: {
                  type: "plain_text_input",
                  action_id: "title_input",
                  initial_value: text_payload
                },
                label: {
                  type: "plain_text",
                  text: I18n.t("slack.commands.create.modal.labels.title")
                }
              },
              {
                type: "input",
                element: {
                  type: "plain_text_input",
                  multiline: true,
                  action_id: "description_input"
                },
                label: {
                  type: "plain_text",
                  text: I18n.t("slack.commands.create.modal.labels.description"),
                  emoji: true
                },
                optional: true
              },
              {
                type: "input",
                element: {
                  type: "static_select",
                  placeholder: {
                    type: "plain_text",
                    text: I18n.t("slack.commands.create.modal.inputs.severity"),
                    emoji: true
                  },
                  options: [
                    {
                      text: {
                        type: "plain_text",
                        text: I18n.t("slack.commands.create.modal.inputs.sev0"),
                        emoji: true
                      },
                      value: "sev0"
                    },
                    {
                      text: {
                        type: "plain_text",
                        text: I18n.t("slack.commands.create.modal.inputs.sev1"),
                        emoji: true
                      },
                      value: "sev1"
                    },
                    {
                      text: {
                        type: "plain_text",
                        text: I18n.t("slack.commands.create.modal.inputs.sev2"),
                        emoji: true
                      },
                      value: "sev2"
                    }
                  ],
                  action_id: "severity_selection"
                },
                label: {
                  type: "plain_text",
                  text: I18n.t("slack.commands.create.modal.labels.severity"),
                  emoji: true
                },
                optional: true
              }
            ]
          }
        )
        head 200
      when "resolve"
        incident = Incident.find_by(external_slack_channel_id: params["channel_id"], status: :declared)

        if incident.present?
          incident.update(status: :resolved)

          render json: {
            blocks: [
              {
                type: "section",
                text: {
                  type: "mrkdwn",
                  text: I18n.t(
                    "slack.commands.create.resolve.success",
                    incident: incident.title,
                    elapsed_time: distance_of_time_in_words(incident.created_at, incident.updated_at)
                  )
                }
              }
            ]
          }
        else
          render json: {
            blocks: [
              {
                type: "section",
                text: {
                  type: "mrkdwn",
                  text: I18n.t("slack.commands.create.resolve.not_found")
                }
              }
            ]
          }
        end
      when "help"
        render json: {
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: I18n.t("slack.commands.create.help.text")
              }
            }
          ]
        }
      else
        json_error_response
      end
    end

    private

    def json_error_response
      render json: {
        blocks: [
          {
            type: "section",
            text: {
              type: "plain_text",
              text: I18n.t("slack.commands.create.error")
            }
          }
        ]
      }
    end
  end
end
