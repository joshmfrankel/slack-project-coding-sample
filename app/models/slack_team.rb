# frozen_string_literal: true

class SlackTeam < ApplicationRecord
  validates :access_token, presence: true
  validates :external_team_id, presence: true, uniqueness: true

  encrypts :access_token
end
