# frozen_string_literal: true

require "test_helper"

class IncidentTest < ActiveSupport::TestCase
  context "validations" do
    should "return invalid without title" do
      incident = Incident.new(title: nil, external_slack_user_id: "test")

      assert incident.invalid?
    end

    should "return invalid without external_slack_user_id" do
      incident = Incident.new(title: "test", external_slack_user_id: nil)

      assert incident.invalid?
    end

    should "return valid with required attributes" do
      incident = Incident.new(title: "test", external_slack_user_id: "slack_id")

      assert incident.valid?
    end
  end

  context "#slack_channel_name" do
    should "return properly formatted channel name without spaces at a maximum of 21 characters" do
      incident = Incident.new(
        id: 12345,
        title: "My first incident"
      )

      assert_equal "12345-my-first-incident", incident.slack_channel_name
    end
  end
end
