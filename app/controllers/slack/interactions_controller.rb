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

      interaction_transformer = Slack::InteractionsTransformer.new(params["payload"])

      case interaction_transformer.callback_id
      when CREATE_INCIDENT_MODAL_CALLBACK_ID
        incident = Incident.new(
          title: interaction_transformer.formatted_state_values["title_input"],
          description: interaction_transformer.formatted_state_values["description_input"],
          severity: interaction_transformer.formatted_state_values["severity_selection"],
          status: :declared,
          external_slack_user_id: interaction_transformer.slack_user_id
        )

        # Future: This could be moved into a Sidekiq background job. Slack
        # response_actions only have a threshold of 3 seconds to send so if
        # we made this asynchronous we'd need to utilize the API to send
        # a response message instead of a json payload
        service = CreateIncidentService.new(new_incident: incident).call

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
        logger.info "#{interaction_transformer.callback_id} does not have an interactions endpoint implementation"

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
