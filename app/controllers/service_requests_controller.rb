class ServiceRequestsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    # Mis solicitudes
    @latest_request = ServiceRequest.where(:user_id => current_user.id, :status => ServiceRequest::ACTIVE).order('created_at DESC').first
    render :layout => false
  end

  def live_search
    @requests = ServiceRequest.includes(:user).where('service_requests.status = :s AND 
                                                     (service_requests.user_id = :u 
                                                      OR service_requests.supervisor_id = :u 
                                                      OR (users.require_auth = 1 AND 
                                                            (users.supervisor1_id = :u OR users.supervisor2_id = :u)
                                                          )
                                                      )', {:s => ServiceRequest::ACTIVE, :u => current_user.id}).order('service_requests.created_at DESC')
    if !params[:q].blank?
      @requests = @requests.where("(description LIKE :q OR number LIKE :q OR request_link LIKE :q)", {:q => "%#{params[:q]}%"}) 
    end
    if !params[:folder_filter].blank? && params[:folder_filter] != '*'
      @requests = @requests.where("(request_type_id = :t)", {:t => params[:folder_filter]}) 
    end
    render :layout => false
  end

  def sample_list
    @request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def show
    @request = ServiceRequest.find(params[:id])
    if (@request.status == ServiceRequest::ACTIVE) 
      render :layout => false
    else
      render :inline => "Carpeta eliminada"
    end
  end

  def new
    @request = ServiceRequest.new
    render :layout => false
  end

  def create 
    params[:service_request][:user_id] = current_user.id
    @service_request = ServiceRequest.new(params[:service_request])
    flash = {}
    if (@service_request.save) 
      flash[:notice] = "Nuevo servicio creado satisfactoriamente (#{@service_request.id})"
      
      # LOG
      @service_request.activity_log.create(user_id: current_user.id, 
                                           message_type: 'CREATE', 
                                           sample_id: 0,
                                           requested_service_id: 0,
                                           message: "Carpeta #{@service_request.number} creada")

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

    flash = {}
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

  def form
    @request_type = RequestType.find(params[:request_type_id])
    template = @request_type.short_name
    render template, :layout => false
  end

end
