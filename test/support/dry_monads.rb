# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

# Convenience methods for easier testing of Dry results from Service objects
def Failure(symbol)
  Dry::Monads::Result::Failure.new(symbol)
end

def Success(symbol)
  Dry::Monads::Result::Success.new(symbol)
end
