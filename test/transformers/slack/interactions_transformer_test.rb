# frozen_string_literal: true

require "test_helper"

module Slack
  class InteractionsTransformerTest < ActiveSupport::TestCase
    context "#new" do
      should "raise exception when payload can't be parsed" do
        assert_raises TypeError do
          Slack::InteractionsTransformer.new(1234)
        end
      end
    end

    context "#callback_id" do
      should "return parsed callback_id" do
        json_payload = {
          view: {
            callback_id: "a-unique-callback"
          }
        }.to_json

        transformer = Slack::InteractionsTransformer.new(json_payload)

        assert_equal "a-unique-callback", transformer.callback_id
      end
    end

    context "#slack_user_id" do
      should "return parsed slack_user_id" do
        json_payload = {
          user: {
            id: "XJFHEIUR"
          }
        }.to_json

        transformer = Slack::InteractionsTransformer.new(json_payload)

        assert_equal "XJFHEIUR", transformer.slack_user_id
      end
    end

    context "#formatted_state_values" do
      should "return all state values formatted by type" do
        json_payload = {
          view: {
            state: {
              values: {
                "4nef" => {
                  title_input: {
                    type: "plain_text_input",
                    value: "My title"
                  }
                },
                "7uN3" => {
                  description_input: {
                    type: "plain_text_input",
                    value: nil # Test optional values
                  }
                },
                "uW1" => {
                  severity_selection: {
                    type: "static_select",
                    selected_option: {
                      value: "sev2"
                    }
                  }
                }
              }
            }
          }
        }.to_json

        transformer = Slack::InteractionsTransformer.new(json_payload)

        expected_state_values = {
          "title_input" => "My title",
          "severity_selection" => "sev2"
        }

        assert_equal expected_state_values, transformer.formatted_state_values
      end
    end
  end
end
