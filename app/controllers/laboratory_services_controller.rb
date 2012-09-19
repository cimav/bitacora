class LaboratoryServicesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  def live_search
    @laboratory_services = LaboratoryService.order('name')

    if params[:service_type] != '0'
      @laboratory_services = @laboratory_services.where(:service_type_id => params[:service_type])
    end  

    if params[:laboratory] != '0'
      @laboratory_services = @laboratory_services.where(:laboratory_id => params[:laboratory])
    end  

    if !params[:q].blank?
      @laboratory_services = @laboratory_services.where("(description LIKE :q OR name LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def for_sample
    @laboratory_service = LaboratoryService.find(params[:id])
    @sample = Sample.find(params[:sample_id])
    render :layout => false
  end
end
