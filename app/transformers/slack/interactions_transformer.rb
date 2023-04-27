# frozen_string_literal: true

module Slack
  class InteractionsTransformer
    attr_reader :parsed_payload

    def initialize(json_payload)
      @parsed_payload = JSON.parse(json_payload)
    end

    def callback_id
      parsed_payload["view"]["callback_id"]
    end

    def slack_user_id
      parsed_payload["user"]["id"]
    end

    # This method accepts state values from Slack response and transforms them
    # into a Hash data structure. Given that it is in Hash format and likely
    # to be used multiple times in a row, this method has been memoized for
    # performance.
    #
    # @example
    # {
    #   title_input: "my title value",
    #   description_input: "my description",
    #   severity_selection: "sev2"
    # }
    def formatted_state_values
      @_formatted_state_values ||= {}.tap do |values_hash|
        parsed_payload["view"]["state"]["values"].each do |_, value|
          values_hash[value.keys[0]] = value[value.keys[0]]["value"]
        end
      end
    end
  end
end
