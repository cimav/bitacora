class ServiceRequestsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    # Mis solicitudes
    @requests = ServiceRequest.where(:user_id => current_user.id)
    render :layout => false
  end

  def live_search
    render :inline => "TODO"
  end

  def new
    @request = ServiceRequest.new
    render :layout => false
  end

  def create 
    params[:service_request][:user_id] = current_user.id
    @service_request = ServiceRequest.new(params[:service_request])
    if (@service_request.save) 
      flash[:notice] = "Nuevo servicio creado satisfactoriamente (#{@service_request.id})"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @service_request.id
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta acción debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo crear el servicio"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @service_request.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @service_request
          end
        end
      end
    end
  end

end
