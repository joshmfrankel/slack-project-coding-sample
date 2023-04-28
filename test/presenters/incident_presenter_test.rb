# frozen_string_literal: true

require "test_helper"

class IncidentPresenterTest < ActiveSupport::TestCase
  context "#status_classes" do
    should "return declared classes" do
      incident = Incident.new(status: :declared)
      presenter = IncidentPresenter.new(incident)

      assert_equal "text-rose-500", presenter.status_classes
    end

    should "return resolved classes" do
      incident = Incident.new(status: :resolved)
      presenter = IncidentPresenter.new(incident)

      assert_equal "text-green-400", presenter.status_classes
    end
  end
end
