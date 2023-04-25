class SlackCommandsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # return unless params[:command] == "/rootly"
    # return unless text_command is declare, resolve, or help
    text_command = params[:text].split(" ").first
    text_payload = params[:text] #TODO: Remove rest

    # TODO: Determine approach given the incoming command

    case text_command
    when "declare"
      client = Slack::Web::Client.new
      client.views_open(
        trigger_id: params[:trigger_id],
        view: {
          type: "modal",
          callback_id: "modal-identifier",
          title: {
            type: "plain_text",
            text: text_payload
          },
          submit: {
            type: "plain_text",
            text: "Submit"
          },
          blocks: [
    {
      "type": "input",
      "element": {
        "type": "plain_text_input",
        "action_id": "title_input"
      },
      "label": {
        "type": "plain_text",
        "text": "Title"
      }
    },
    {
      "type": "input",
      "element": {
        "type": "plain_text_input",
        "multiline": true,
        "action_id": "description_input"
      },
      "label": {
        "type": "plain_text",
        "text": "Description",
        "emoji": true
      }
    },
    {
      "type": "input",
      "element": {
        "type": "static_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select a severity level",
          "emoji": true
        },
        "options": [
          {
            "text": {
              "type": "plain_text",
              "text": "sev0",
              "emoji": true
            },
            "value": "sev0"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "sev1",
              "emoji": true
            },
            "value": "sev1"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "sev2",
              "emoji": true
            },
            "value": "sev2"
          }
        ],
        "action_id": "severity_selection"
      },
      "label": {
        "type": "plain_text",
        "text": "Severity",
        "emoji": true
      }
    }
  ]
        }
      )
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
      render json: {
        blocks: [
          {
            type: "section",
            text: {
              type: "plain_text",
              text: "We're sorry. This command wasn't recognized.",
            }
          }
        ]
      }
    end
  end
end
