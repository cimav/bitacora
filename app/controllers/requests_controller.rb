class RequestsController < ApplicationController
  before_filter :auth_required
  def index
    # Mis solicitudes
    @lab_requests = LaboratoryRequest.where(:user_id => current_user.id)
  end
end
