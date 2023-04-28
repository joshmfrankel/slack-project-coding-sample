# frozen_string_literal: true

class CreateSlackTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_teams do |t|
      t.string :external_team_id, null: false
      t.string :access_token, null: false

      t.timestamps
    end
  end
end
