# frozen_string_literal: true

require "test_helper"

class IncidentsControllerTest < ActionDispatch::IntegrationTest
  context "GET #index" do
    should "return success status" do
      get incidents_path

      assert_response :success
    end
  end
end
