# frozen_string_literal: true

class IncidentsController < ApplicationController
  def index
    incidents = IncidentQuery.new(
      Incident,
      sort: params[:sort],
      severity: params[:severity],
      status: params[:status]
    ).call

    @pagy, @incidents = pagy(incidents)
  end
end
