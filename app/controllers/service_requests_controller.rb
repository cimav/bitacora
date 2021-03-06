# coding: utf-8
require 'resque-bus'
class ServiceRequestsController < ApplicationController
  before_filter :auth_required, :except => [:enviar_solicitud_presupuesto]
  respond_to :html, :json

  def index
    # Mis solicitudes
    @latest_request = ServiceRequest.where(:user_id => current_user.id, :status => ServiceRequest::ACTIVE).order('created_at DESC').first
    
    @request_types = ServiceRequest.find_by_sql (["SELECT request_type_id AS id, request_types.name, COUNT(*) AS how_many
                                                   FROM 
                                                     service_requests
                                                     LEFT JOIN users 
                                                       ON service_requests.user_id = users.id
                                                     LEFT JOIN request_types 
                                                       ON service_requests.request_type_id = request_types.id
                                                   WHERE 
                                                     (service_requests.user_id = :u 
                                                      OR service_requests.supervisor_id = :u 
                                                      OR (users.require_auth = 1 AND 
                                                            (users.supervisor1_id = :u OR users.supervisor2_id = :u)
                                                          )
                                                      OR (:u IN (SELECT user_id FROM collaborators WHERE service_request_id = service_requests.id))
                                                      ) 
                                                     AND service_requests.status = :s
                                                   GROUP BY service_requests.request_type_id 
                                                   ORDER BY request_types.name", 
                                                   :u => current_user.id, 
                                                   :s => ServiceRequest::ACTIVE])

    render :layout => false
  end

  def live_search
    cs1 = ServiceRequest::SERVICIO_VINCULACION_NO_COORDINADO
    cs2 = ServiceRequest::SERVICIO_VINCULACION_TIPO_2
    cs3 = ServiceRequest::SERVICIO_VINCULACION

    if params[:o] && params[:o].to_i > 0 
      @offset = params[:o]
    else
      @offset = 0
    end
    @limit = 50

    if params[:q]
      @q = params[:q]
    else
      @q = ''
    end
    
    if current_user.access.to_i == User::ACCESS_CUSTOMER_SERVICE
      extra_sql = "OR ( request_type_id = :cs1 OR request_type_id = :cs2 OR request_type_id = :cs3 )"
    else
      extra_sql = ""
    end
    
    @requests = ServiceRequest.joins(:user).includes(:request_type).includes(:user).includes(:collaborators).where("service_requests.status = :s AND 
                                                     (service_requests.user_id = :u " + extra_sql + "
                                                      OR service_requests.supervisor_id = :u 
                                                      OR (:u IN (SELECT user_id FROM collaborators WHERE service_request_id = service_requests.id))
                                                      OR (users.require_auth = 1 AND 
                                                            (users.supervisor1_id = :u OR users.supervisor2_id = :u)
                                                          )
                                                      )", {:s => ServiceRequest::ACTIVE, :u => current_user.id, :cs1 => cs1, :cs2 => cs2, :cs3 => cs3, :cs_a => User::ACCESS_CUSTOMER_SERVICE}).order('service_requests.created_at DESC')

    if !params[:q].blank?
      @requests = @requests.where("(description LIKE :q OR number LIKE :q OR request_link LIKE :q)", {:q => "%#{params[:q]}%"}) 
    end
    if !params[:folder_filter].blank? && params[:folder_filter] != '*'
      @requests = @requests.where("(request_type_id = :t)", {:t => params[:folder_filter]}) 
    end
    
    #@requests = @requests.order('service_requests.created_at DESC').limit(@limit).offset(@offset)
    @requests = @requests.order('service_requests.created_at DESC')
    render :layout => false
  end

  def actions
    @request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def show
    @request = ServiceRequest.find(params[:id])
    
    cs1 = ServiceRequest::SERVICIO_VINCULACION_NO_COORDINADO
    cs2 = ServiceRequest::SERVICIO_VINCULACION_TIPO_2
    cs3 = ServiceRequest::SERVICIO_VINCULACION
    cs4 = ServiceRequest::PROYECTO_VINCULACION

    collaborators = @request.collaborators.map { |c| c.user_id }
    authorized = current_user.is_admin? ||
                 @request.user_id == current_user.id ||
                 @request.supervisor_id == current_user.id ||
                 @request.user.supervisor1_id == current_user.id ||
                 @request.user.supervisor2_id == current_user.id ||
                 (collaborators.include? current_user.id) ||
                 ( (@request.request_type_id == cs1 || @request.request_type_id == cs2 || @request.request_type_id == cs3 || @request.request_type_id == cs4) && current_user.access.to_i == User::ACCESS_CUSTOMER_SERVICE)         

    if !authorized
      render :inline => '<div class="sheet"><div class="app-message">No Autorizado</div></div>'.html_safe                   
    elsif (@request.status == ServiceRequest::ACTIVE) 
      if @request.request_type_id == ServiceRequest::PROYECTO_VINCULACION && @request.system_status == ServiceRequest::SYSTEM_TO_QUOTE 
        render "quote_project", :layout => false
      else
        render :layout => false
      end
    else
      render :inline => 'Carpeta Eliminada'
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
            json[:number] = @service_request.number
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

  def edit_dialog
    @service_request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def solicitar_presupuesto_dialog
    @service_request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def enviar_solicitud_presupuesto
    @service_request = ServiceRequest.find(params[:id])
    begin  
	    sql_stmt = "select sum(price) from requested_services rs
        	join requested_service_others others on rs.id = others.requested_service_id
        	where rs.number like '#{@service_request.number}%'"
    		price =  ActiveRecord::Base.connection.execute(sql_stmt)
        	if price && price.first[0] > 10
     			 BitacoraMailer.enviar_presupuesto(@service_request).deliver

      			@service_request.presupuesto_enviado = true
      			@service_request.save

      			render :inline => "Hoja de presupuesto enviada", :layout => false
    		else
      			render :inline => "No se solicitan presupuestos en ceros", :layout => false
    		end
    rescue => e
        render :inline => "Excepción: No se solicitan presupuestos en ceros", :layout => false
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
            json[:id] = @request.id
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
            json[:id] = params[:id]
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

  def quotation
    @request = ServiceRequest.find(params[:id])
    @details = cost_details(@request)
    render :layout => false
  end

  def send_quote
    # Publish recibir_costeo to Vinculacion system.
    request = ServiceRequest.find(params[:id])
    request.suggested_price = params[:suggested_price]
    request.estimated_time = params[:estimated_time]
    details = cost_details(request)
    QueueBus.publish('recibir_costeo', cost_details(request))
    request.system_status = ServiceRequest::SYSTEM_QUOTE_SENT
    request.save

    # Send mail to Vinculacion
    Resque.enqueue(CosteoEnviadoMailer, request.id)


    render :layout => false
  end

  def view_report
    @request = ServiceRequest.find(params[:id])
    @details = cost_details(@request)
    @participants = []

    @participants << @request.user

    @request.requested_services.each do |rs|
      if rs.status.to_i != RequestedService::CANCELED  && rs.status.to_i != RequestedService::DELETED  
        rs.requested_service_technicians.each do |t|
          if !@participants.include? t.user
            @participants << t.user
          end
        end
      end
    end
    puts @participants
    
    render :layout => false
  end

  def view_report_tipo_2
    @request = ServiceRequest.find(params[:id])
    @details = cost_details(@request)
    @participants = []

    @participants << @request.user

    @request.requested_services.each do |rs|
      if rs.status.to_i != RequestedService::CANCELED  && rs.status.to_i != RequestedService::DELETED  
        rs.requested_service_technicians.each do |t|
          if !@participants.include? t.user
            @participants << t.user
          end
        end
      end
    end
    puts @participants
    
    render :layout => false
  end

  def send_report

    request = ServiceRequest.find(params[:id])

    params['user'].each do |user_id,percentage|
      participation = request.service_request_participations.new
      participation.user_id = user_id
      participation.percentage = percentage
      participation.save
    end  

    participations = Array.new
    request.service_request_participations.each do |p|
      participations << {
        "email" => p.user.email,
        "porcentaje" => p.percentage,
      }
    end

    # Publish reporte to Vinculacion system.
    details = cost_details(request)
    details['participaciones'] = participations
    QueueBus.publish('recibir_reporte', details)
    request.system_status = ServiceRequest::SYSTEM_REPORT_SENT
    request.save


    # Send mail to Vinculacion
    Resque.enqueue(ReporteEnviadoMailer, request.id)

    render :layout => false
  end

  def send_report_tipo_2

    request = ServiceRequest.find(params[:id])

    # Publish reporte to Vinculacion system.
    details = cost_details(request)
    #details['participaciones'] = participations
    puts "DETALLES"
    puts details
    QueueBus.publish('recibir_reporte_tipo_2', details)
    request.system_status = ServiceRequest::SYSTEM_REPORT_SENT
    request.save
    render :layout => false
  end

  def add_collaborator_dialog
    @request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def add_collaborator
    @request = ServiceRequest.find(params[:id])
    collaborator = @request.collaborators.new
    collaborator.user_id = params[:collaborator_id]
    collaborator.save

    # Send mail to Collaborator
    collab_email= User.find(collaborator.user_id).email rescue "no-email-de-colaborador"
    Resque.enqueue(NotifyNewCollaboratorMailer, @request.id, collab_email)

    #BitacoraMailer.notify_new_collaborator(@request, collab_email).deliver

    render :layout => false
  end

  def get_collaborators
    @request = ServiceRequest.find(params[:id])
    render :layout => false
  end

  def delete_collaborator 
    flash = {}
    collaborator = Collaborator.find(params[:collaborator_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if collaborator.destroy
      flash[:notice] = "Participante eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = collaborator.id
            render :json => json
          else
            redirect_to collaborator
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el participante."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = collaborator.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to collaborator
          end
        end
      end
    end
  end

  def folder_without_services
    puts "FOLDER WO SERVICES"
    @service_request = ServiceRequest.find(params[:id])
    @activity_log = ActivityLog.where("service_request_id = :service_request", {:service_request => @service_request.id}).order('id DESC')
    render :layout => false
  end

  def files_list
     @service_request = ServiceRequest.find(params[:id])
     render :layout => false
  end


  def send_request_department_auth
    @service_request = ServiceRequest.find(params[:id])
    if @service_request
      if Resque.enqueue(RequestDepartmentAuthMailer, @service_request.id)
        flash[:notice] = "Solicitud de autorización enviada al Jefe de Departamento"

        respond_with do |format|
          format.html do
            if request.xhr?
              json = {}
              json[:flash] = flash
              json[:id] = @service_request.id
              render :json => json
            else
              redirect_to @service_request
            end
          end
        end
      else

        respond_with do |format|
          format.html do
            if request.xhr?
              json = {}
              flash[:error] = "No se pudo enviar solicitud de autorización"
              json[:errors] = @service_request.errors
              json[:flash] = flash
              json[:id] = @service_request.id
              render :json => json, :status => :unprocessable_entity
            else
              redirect_to @service_request
            end
          end
        end

      end
    else

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            flash[:error] = "No se pudo accesar a la carpeta con ID #{params[:id]}"
            json[:errors] = @service_request.errors
            json[:flash] = flash
            json[:id] = @service_request.id
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @service_request
          end
        end
      end

    end
    
  end

  def department_supervisor_auth
    @service_request = ServiceRequest.where("vinculacion_hash = ?", params[:hash]).first

    if !@service_request 
      render :inline => "Error, no encontrado"
    else
      @h = params[:hash]
      @project_quote = @service_request.active_quote
      render :layout => 'standalone'
    end
  end

  private
  def cost_details(service_request)
    
    services_costs = []

    service_request.sample.each do |s|
      s.requested_service.where("status != ? AND status != ?", RequestedService::DELETED, RequestedService::CANCELED).each do |rs|
        services_costs << cost_details_requested_service(rs)
      end
    end
    
    details = {
      "system_id" => service_request.system_id, 
      "system_request_id" => service_request.system_request_id, 
      "codigo" => service_request.number, 
      "precio_sugerido" => service_request.suggested_price,
      "tiempo_estimado" => service_request.estimated_time,
      "servicios" => services_costs
    }
    
    return details
  
  end

  def cost_details_requested_service(requested_service)

    # Technicians
    technicians = Array.new
    cedula_id = requested_service.cedula_id
    requested_service.requested_service_technicians.each do |tech|
      technicians << {
        "detalle" => tech.user.full_name,
        "email" => tech.user.email,
        "cantidad" => tech.hours,
        "precio_unitario" => tech.hourly_wage, 
        "cedula" => cedula_id,
        "porcentaje" => tech.participation
      }
    end

    # Equipment
    equipment = Array.new
    requested_service.requested_service_equipments.each do |eq|
      equipment << {
        "detalle" => eq.equipment.name,
        "cantidad" => eq.hours,
        "precio_unitario" => eq.hourly_rate,
        "cedula" => cedula_id
      }
    end


    # Others
    others = Array.new
    requested_service.requested_service_others.each do |ot|
      others << {
        "detalle" => "#{ot.other_type.name}: #{ot.concept}",
        "cantidad" => 1,
        "precio_unitario" => ot.price,
        "cedula" => cedula_id
      }
    end

    # Details
    details = {
      "bitacora_id"           => requested_service.id,
      "muestra_system_id"     => requested_service.sample.system_id,
      "muestra_identificador" => requested_service.sample.identification,
      "nombre_servicio"       => requested_service.laboratory_service.name,
      "es_catalogo"           => requested_service.service_quote_type == RequestedService::QUOTE_USE_CATALOG,
      "personal"              => technicians,
      "equipos"               => equipment,
      "otros"                 => others,
      "legend"                => requested_service.legend
    }

    return details
  end





end
