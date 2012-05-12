class ServiceFilesController < ApplicationController
  def ui
    @service_request_id = params[:service_request_id]
    @sample_id = params[:sample_id] 
    @requested_service_id = params[:requested_service_id]
    @files = Hash.new
    render :layout => false
  end
end
