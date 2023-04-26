# frozen_string_literal: true

module Slack
  # Entry point for all interactions that take place within Slack interface
  # Note: Channel names have a 21-character limit and can include lowercase letters, non-Latin characters, numbers, and hyphens.
  # @see https://help.nintex.com/en-us/nwc/Content/Designer/Actions/Slack-CreateaChannel.htm
  class InteractionsController < ApplicationController
    include Slack::VerifyRequestSignature

    skip_before_action :verify_authenticity_token

    def create
      # TODO: Check for interaction type modal-interaction-id
      if params["payload"].present?
        parsed_form_data = {}

        # TODO: Dedicated Parser class
        parsed_payload = JSON.parse(params["payload"])
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

        if incident.save
          client = Slack::Web::Client.new
          create_channel_result = client
            .conversations_create(
              name: incident.slack_channel_name
            )

          if create_channel_result["ok"]
            client.conversations_join(channel: create_channel_result["channel"]["id"])

            # TODO: Respond with success message telling user to join #channel
            head 200
          else
            slack_service_error_response
          end
        else
          # TODO: failed to create incident message db
        end
      else
        slack_service_error_response
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
