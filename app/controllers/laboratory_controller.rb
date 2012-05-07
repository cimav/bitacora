class LaboratoryController < ApplicationController
  def show
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def live_search
    @requested_services = RequestedService.where('laboratory_service_id IN (SELECT id FROM laboratory_services WHERE laboratory_id = :lab)',  {:lab => params[:id]})
    render :layout => false
  end

end
