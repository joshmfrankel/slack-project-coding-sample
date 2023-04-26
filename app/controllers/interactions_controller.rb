class InteractionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # API: conversations_create
  # required scope: channels:manage
  # @see https://api.slack.com/methods/conversations.create
  #
  # API: conversations_join
  # required scope: channels:join
  # @see https://api.slack.com/methods/conversations.join
  def create
    client = Slack::Web::Client.new
    channel_name = "my-first-channel" # todo: incident id and title

    # TODO: Name taken?
    result = client.conversations_create(name: channel_name)


    if result["ok"]
      client.conversations_join(channel: result["channel"]["id"])

         # Hash of values from Form submission
         # => [{"title_input"=>{"type"=>"plain_text_input", "value"=>"This should be named"}},
      # {"description_input"=>{"type"=>"plain_text_input", "value"=>"more details"}},
      # {"severity_selection"=>{"type"=>"static_select", "selected_option"=>{"text"=>{"type"=>"plain_text", "text"=>"sev1", "emoji"=>true}, "value"=>"sev1"}}}]
         JSON.parse(params["payload"])["view"]["state"]["values"].values
         head 200
    else
      #TODO:
      render json: {
        blocks: [
          {
            type: "section",
            text: {
              type: "plain_text",
              text: "There was an issue creating the incident channel."
            }
          }
        ]
      }
    end
  end
end
