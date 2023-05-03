# frozen_string_literal: true

module Slack
  module Constants
    extend ActiveSupport::Concern

    CREATE_INCIDENT_MODAL_CALLBACK_ID = "declare-incident-modal"
    SLACK_URL = "https://slack.com"
  end
end
