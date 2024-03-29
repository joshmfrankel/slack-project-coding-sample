# frozen_string_literal: true

module Slack
  # Entry point for all interactions that take place within Slack interface
  # @see https://help.nintex.com/en-us/nwc/Content/Designer/Actions/Slack-CreateaChannel.htm
  class InteractionsController < ApplicationController
    include Slack::VerifyRequestSignature
    include Slack::Constants

    skip_before_action :verify_authenticity_token

    def create
      return slack_service_error_response unless params[:payload].present?

      interaction_transformer = Slack::InteractionsTransformer.new(params["payload"])

      # Determine correct team for interacting with Slack API
      slack_team = SlackTeam.find_by(external_team_id: interaction_transformer.slack_team_id)

      return slack_service_error_response unless slack_team.present?

      case interaction_transformer.callback_id
      when CREATE_INCIDENT_MODAL_CALLBACK_ID
        incident = Incident.new(
          title: interaction_transformer.formatted_state_values["title_input"],
          description: interaction_transformer.formatted_state_values["description_input"],
          severity: interaction_transformer.formatted_state_values["severity_selection"],
          status: :declared,
          external_slack_user_id: interaction_transformer.slack_user_id,
          external_slack_user_name: interaction_transformer.slack_user_name
        )

        # Future: This could be moved into a Sidekiq background job to offload
        # processing into asynchronous queue.
        service = CreateIncidentService.new(
          new_incident: incident,
          slack_client: Slack::Web::Client.new(token: slack_team.access_token)
        ).call

        if service.success?
          head :ok
        else

          # Limitation: `view_submission` payloads have a 3 second window to
          # respond with json to a request. If the service above takes longer
          # than that the following response won't be sent. Switching to the
          # chat_postMessage api endpoint may be useful in the future
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
