class ServiceRequestsController < ApplicationController
  before_filter :auth_required
  def index
    # Mis solicitudes
    @requests = ServiceRequest.where(:user_id => current_user.id)
    render :layout => false
  end

  def new_request
    @request = ServiceRequest.new
    render :layout => false
  end

end
