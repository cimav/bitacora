class LaboratoryServicesController < ApplicationController
  def live_search
    @laboratory_services = LaboratoryService.order('name')
    render :layout => false
  end

  def for_sample
    @laboratory_service = LaboratoryService.find(params[:id])
    @sample = Sample.find(params[:sample_id])
    render :layout => false
  end
end
