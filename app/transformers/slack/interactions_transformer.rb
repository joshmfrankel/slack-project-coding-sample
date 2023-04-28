# frozen_string_literal: true

module Slack
  # This transformer ensures incoming JSON Payload data is properly parsed
  # along with providing helpful shortcuts to important pieces of response data.
  class InteractionsTransformer
    attr_reader :parsed_payload

    def initialize(json_payload)
      @parsed_payload = json_payload.is_a?(Hash) ? json_payload : JSON.parse(json_payload)
    end

    def callback_id
      parsed_payload["view"]["callback_id"]
    end

    def slack_user_id
      parsed_payload["user"]["id"]
    end

    def slack_team_id
      parsed_payload["team"]["id"]
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
          values_hash[value.keys[0]] = case value[value.keys[0]]["type"]
          when "static_select"
            next if value[value.keys[0]]["selected_option"].nil?
            value[value.keys[0]]["selected_option"]["value"]
          when "plain_text_input"
            next if value[value.keys[0]]["value"].nil?
            value[value.keys[0]]["value"]
          else
            logger.info "No transformer implementation for #{value[value.keys[0]]["type"]}"

            # Utilize default value parsing in the absence of specific transformer
            # type implementation above
            value[value.keys[0]]["value"]
          end
        end
      end
    end
  end
end
