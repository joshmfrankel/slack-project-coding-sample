# frozen_string_literal: true

class IncidentPresenter < SimpleDelegator
  def initialize(incident)
    @incident = incident
    super
  end

  def status_classes
    if declared?
      "text-rose-500"
    else
      "text-green-400"
    end
  end
end
