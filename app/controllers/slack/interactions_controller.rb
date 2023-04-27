# frozen_string_literal: true

module Slack
  # Entry point for all interactions that take place within Slack interface
  # Note: Channel names have a 21-character limit and can include lowercase letters, non-Latin characters, numbers, and hyphens.
  # @see https://help.nintex.com/en-us/nwc/Content/Designer/Actions/Slack-CreateaChannel.htm
  class InteractionsController < ApplicationController
    include Slack::VerifyRequestSignature
    include Slack::Constants

    skip_before_action :verify_authenticity_token

    def create
      return slack_service_error_response unless params[:payload].present?

      parsed_payload = JSON.parse(params["payload"])

      case parsed_payload["view"]["callback_id"]
      when CREATE_INCIDENT_MODAL_CALLBACK_ID
        parsed_form_data = {}
        # TODO: Dedicated Parser class
        parsed_payload["view"]["state"]["values"].each do |_, value|
          parsed_form_data[value.keys[0]] = value[value.keys[0]]["value"]
        end

        external_slack_user_id = parsed_payload["user"]["id"]

        incident = Incident.new(
          title: parsed_form_data["title_input"],
          description: parsed_form_data["description_input"],
          severity: parsed_form_data["severity_selection"],
          status: :declared,
          external_slack_user_id: external_slack_user_id
        )

        # Future: This could be moved into a Sidekiq background job. Slack
        # response_actions only have a threshold of 3 seconds to send so if
        # we made this asynchronous we'd need to utilize the API to send
        # a response message instead of a json payload
        service = CreateIncidentService.new(incident: incident).call

        if service.success?
          head :ok
        else

          # Limitation: `view_submission` payloads have a 3 second window to
          # respond with json to a request. If the service above takes longer
          # than that the following response won't be sent. Possibly fixed with
          # a background job as described above.
          render json: {
            response_action: "update",
            view: {
              type: "modal",
              title: {
                type: "plain_text",
                text: "Error encountered"
              },
              blocks: [
                {
                  type: "section",
                  text: {
                    type: "plain_text",
                    text: service.failure.second # Service includes user-facing text message
                  }
                }
              ]
            }
          }
        end
      else
        # When the callback_id is unknown we don't want to alert the user but we
        # want to ensure it is easy to debug for engineers.
        logger.info "#{parsed_payload["view"]["callback_id"]} does not have an interactions endpoint implementation"

        head :no_content
      end
    end

    private

    def slack_service_error_response
      render json: {
        blocks: [
          {
            type: "section",
            text: {
              type: "plain_text",
              text: I18n.t("slack.interactions.create.error")
            }
          }
        ]
      }
    end
  end
end
