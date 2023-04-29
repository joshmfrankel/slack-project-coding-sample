# frozen_string_literal: true

require "test_helper"

class IncidentQueryTest < ActiveSupport::TestCase
  context "#call" do
    should "sort results by desc" do
      incident = incidents(:declared)
      incident.update(created_at: 5.days.ago)

      query = IncidentQuery.new(Incident, sort: :desc).call

      assert_equal query, [incidents(:resolved), incidents(:declared)]
    end

    should "filter results by severity" do
      query = IncidentQuery.new(Incident, severity: 2).call

      assert_equal query, [incidents(:resolved)]
    end

    should "filter results by status" do
      query = IncidentQuery.new(Incident, status: :declared).call

      assert_equal query, [incidents(:declared)]
    end
  end
end
