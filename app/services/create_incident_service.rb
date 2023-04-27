# frozen_string_literal: true

class CreateIncidentService < ApplicationService
  def initialize(incident:)
    @incident = incident
    @slack_client = Slack::Web::Client.new
  end

  def call
    persisted_incident = yield save_incident
    create_channel_result = yield create_incident_channel(persisted_incident)
    join_channel_result = yield join_channel_as_bot(create_channel_result)

    Success([persisted_incident, create_channel_result, join_channel_result])
  end

  private

  def save_incident
    if @incident.save
      Success(@incident)
    else
      Failure[:failed_to_save_incident_in_db, @incident.errors]
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
      Failure[:failed_to_create_channel]
    end
  end

  def join_channel_as_bot(create_channel_result)
    join_channel_result = @slack_client
      .conversations_join(
        channel: create_channel_result["channel"]["id"]
      )

    if join_channel_result["ok"]
      Success(join_channel_result)
    else
      Failure[:failed_to_join_channel]
    end
  end
end
