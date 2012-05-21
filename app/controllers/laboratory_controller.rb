class LaboratoryController < ApplicationController
  def show
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def live_search
    @requested_services = RequestedService.joins(:sample).joins(:laboratory_service).where('laboratory_id = :lab',  {:lab => params[:id]})
    if params[:lrs_status] != '0'
      @requested_services = @requested_services.where('requested_services.status' => params[:lrs_status])
    end
    if params[:lrs_requestor] != '0'
      @requested_services = @requested_services.where('samples.service_request_id IN (SELECT id FROM service_requests WHERE user_id = :req)', {:req => params[:lrs_requestor]})
    end
    if params[:lrs_assigned_to] != '0'
      @requested_services = @requested_services.where('requested_services.user_id' => params[:lrs_assigned_to])
    end
    if !params[:q].blank?
      @requested_services = @requested_services.where("(laboratory_services.description LIKE :q OR laboratory_services.name LIKE :q OR samples.identification LIKE :q OR samples.identification LIKE :q OR samples.description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

end
