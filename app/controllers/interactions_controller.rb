class InteractionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # Hash of values
    # => [{"title_input"=>{"type"=>"plain_text_input", "value"=>"This should be named"}},
 # {"description_input"=>{"type"=>"plain_text_input", "value"=>"more details"}},
 # {"severity_selection"=>{"type"=>"static_select", "selected_option"=>{"text"=>{"type"=>"plain_text", "text"=>"sev1", "emoji"=>true}, "value"=>"sev1"}}}]
    JSON.parse(params["payload"])["view"]["state"]["values"].values
  end
end
