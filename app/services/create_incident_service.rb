# frozen_string_literal: true

# Contains all related business logic for creating a new Incident
class CreateIncidentService < ApplicationService
  def initialize(new_incident:)
    @incident = new_incident
    @slack_client = Slack::Web::Client.new
  end

  def call
    persisted_incident = yield save_incident
    create_channel_result = yield create_incident_channel(persisted_incident)
    yield post_success_message(create_channel_result)

    Success([persisted_incident, create_channel_result])
  end

  private

  def save_incident
    if @incident.save
      Success(@incident)
    else
      Failure[:failed_to_save_incident_in_db, @incident.errors.map(&:full_message).to_sentence]
    end
  end

  def create_incident_channel(persisted_incident)
    create_channel_result = @slack_client
      .conversations_create(
        name: persisted_incident.slack_channel_name
      )

    if create_channel_result["ok"]
      Success(create_channel_result)
    else
      Failure[:failed_to_create_channel, "Channel could not be created. Please try again later."]
    end
  end

  def post_success_message(create_channel_result)
    channel_id = create_channel_result["channel"]["id"]

    post_message_result = @slack_client.chat_postMessage(
      channel: channel_id,
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "#{@incident.title} was created by #{@incident.external_slack_user_id_mention} in #{slack_channel_format(channel_id)}"
          }
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Severity*: #{@incident.severity}"
          }
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Description*: #{@incident.description}"
          }
        }
      ]
    )

    if post_message_result["ok"]
      Success(post_message_result)
    else
      Failure[:failed_to_post_message, "Bot was unable to post message. Please try again later."]
    end
  end

  private

  def slack_channel_format(channel_id)
    "<##{channel_id}>"
  end
end
