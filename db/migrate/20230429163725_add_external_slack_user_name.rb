# frozen_string_literal: true

class AddExternalSlackUserName < ActiveRecord::Migration[7.0]
  def change
    add_column :incidents, :external_slack_user_name, :string
  end
end
