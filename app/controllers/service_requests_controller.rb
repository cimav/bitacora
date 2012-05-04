class ServiceRequestsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    # Mis solicitudes
    @latest_request = ServiceRequest.where(:user_id => current_user.id).order('created_at DESC').first
    render :layout => false
  end

  def live_search
    render :inline => "TODO"
  end

  def sample_list
    @request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def show
    @request = ServiceRequest.find(params[:id])
    render :layout => false
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
      
      # LOG
      @service_request.activity_log.create(user_id: current_user, message: 'Carpeta creada')

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @service_request.id
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
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

  def update 
    @request = ServiceRequest.find(params[:id])

    if @request.update_attributes(params[:service_request])
      flash[:notice] = "Servicio actualizado"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else 
            redirect_to @request
          end
        end
      end
    else
      flash[:error] = "Error al actualizar el servicio."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @request.errors
            render :json => json, :status => :unprocessable_entity
          else 
            redirect_to @request
          end
        end
      end
    end
  end

end
