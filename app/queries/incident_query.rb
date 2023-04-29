# frozen_string_literal: true

class IncidentQuery < ApplicationController
  def initialize(scope, sort: "desc", severity: nil, status: nil)
    @scope = scope
    @sort = sort
    @sort = ["asc", "desc"].include?(sort) ? sort : :desc
    @severity = severity
    @status = status
  end

  def call
    result = @scope.order(created_at: @sort)
    result = result.where(severity: @severity) if @severity.present?
    result = result.where(status: @status) if @status.present?
    result
  end
end
