# frozen_string_literal: true

module Slack
  # Entry point for all `/rootly` Slack Slash commands
  class CommandsController < ApplicationController
    include Slack::VerifyRequestSignature

    skip_before_action :verify_authenticity_token

    def create
      return json_error_response unless params[:text].present?
      text_command, text_payload = params[:text].split(" ", 2)

      case text_command
      when "declare"
        head 200
      when "help"
        render json: {
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "Rootly Commands\n\n* `/rootly declare <title>` - Create a new incident\n* `/rootly resolve` - Resolve an incident from a channel\n* `/rootly help` - Display help options"
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
              text: "We're sorry. This command wasn't recognized."
            }
          }
        ]
      }
    end
  end
end
