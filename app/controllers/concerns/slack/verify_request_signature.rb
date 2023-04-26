# frozen_string_literal: true

# Utilizes slack-ruby-client to perform hmac hash compairson for request
# verification.
#
# @see https://api.slack.com/authentication/verifying-requests-from-slack
module Slack
  module VerifyRequestSignature
    extend ActiveSupport::Concern

    included do
      before_action :verify_signature
    end

    private

    # @see https://github.com/slack-ruby/slack-ruby-client#verifying-the-request-signature
    def verify_signature
      slack_request = Slack::Events::Request.new(request)
      slack_request.verify!
    end
  end
end
