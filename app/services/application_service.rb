# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

class ApplicationService
  include Dry::Monads[:result, :do]
end
