class LaboratoryLoadController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    render :layout => false
  end

  def live_search
    @laboratories = Laboratory.where('status = :s', {:s => Laboratory::ACTIVE}).order('name')
    if !params['load-laboratories-unit'].blank? && params['load-laboratories-unit'] != '0'
      @laboratories = @laboratories.where("business_unit_id = :c", {:c => params['load-laboratories-unit']}) 
    end
    if !params[:q].blank?
      @laboratories = @laboratories.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def show
  	@laboratory = Laboratory.find(params[:id])
  	@received = @laboratory.requested_services.where(:status => RequestedService::RECEIVED)
  	@assigned = @laboratory.requested_services.where(:status => RequestedService::ASSIGNED)
  	@in_progress = @laboratory.requested_services.where(:status => [RequestedService::REINIT, RequestedService::IN_PROGRESS])
  	@quote = @laboratory.requested_services.where(:status => [RequestedService::TO_QUOTE, RequestedService::QUOTE_AUTH])
  	@waiting = @laboratory.requested_services.where(:status => RequestedService::WAITING_START)
  	render :layout => false
  end


end
