# frozen_string_literal: true

class AddExternalSlackChannelIdToIncidents < ActiveRecord::Migration[7.0]
  def change
    add_column :incidents, :external_slack_channel_id, :string
  end
end
