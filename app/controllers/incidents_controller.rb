# frozen_string_literal: true

class IncidentsController < ApplicationController
  def index
    @pagy, @incidents = pagy(Incident.order(created_at: :desc))
  end
end
