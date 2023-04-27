# frozen_string_literal: true

module Render
  class HealthChecksController < ApplicationController
    def index
      head 200
    end
  end
end
