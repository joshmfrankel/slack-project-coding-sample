# frozen_string_literal: true

class Incident < ApplicationRecord
  enum status: {
    declared: 0,
    resolved: 1
  }

  enum severity: {
    sev0: 0,
    sev1: 1,
    sev2: 2
  }

  validates :title, presence: true
  validates :external_slack_user_id, presence: true

  # Slack channel names have several requirements enforced by conversations
  # @see https://api.slack.com/methods/conversations.rename#naming
  def slack_channel_name
    "#{id}-#{title.downcase.tr(" ", "-")}"
  end
end
