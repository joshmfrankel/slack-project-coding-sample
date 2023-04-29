# frozen_string_literal: true

require "test_helper"

class SlackTeamTest < ActiveSupport::TestCase
  context "validations" do
    should "return invalid without access_token" do
      slack_team = SlackTeam.new(access_token: nil, external_team_id: "test")

      assert slack_team.invalid?
    end

    should "return invalid without external_team_id" do
      slack_team = SlackTeam.new(access_token: "my_token", external_team_id: nil)

      assert slack_team.invalid?
    end

    should "return invalid when team_id fails uniqueness constraint" do
      SlackTeam.create(access_token: "my_token", external_team_id: "duplicate")

      slack_team = SlackTeam.new(access_token: "my_token", external_team_id: "duplicate")

      assert slack_team.invalid?
    end

    should "return valid with required attributes" do
      slack_team = SlackTeam.new(access_token: "my_token", external_team_id: "team_id")

      assert slack_team.valid?
    end
  end
end
