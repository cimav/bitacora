# coding: utf-8
class BitacoraMailer < ActionMailer::Base
  default from: "bitacora.electronica@cimav.edu.mx"

  def new_service(requested_service)
  	@from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Requestor  
    @to << requested_service.sample.service_request.user.email
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    @requested_service = requested_service

    subject = "Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def new_tipo1(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Requestor  
    @to << requested_service.sample.service_request.user.email
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    @requested_service = requested_service

    subject = "#{requested_service.sample.service_request.vinculacion_delivery.upcase} Nuevo Servicio T1 #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def new_tipo2(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Requestor  
    @to << requested_service.sample.service_request.user.email
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    @requested_service = requested_service

    subject = "#{requested_service.sample.service_request.vinculacion_delivery.upcase} Nuevo Servicio T2 #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def new_tipo3(service_request)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Coordinator
    @to << service_request.user.email

    @service_request = service_request
    @reply_to = service_request.supervisor.email

    # subject = "#{requested_service.sample.service_request.vinculacion_delivery.upcase} Solicitud de Costeo #{service_request.number}: #{service_request.vinculacion_client_name}"
    subject = "Solicitud de Costeo #{service_request.number}: #{service_request.vinculacion_client_name}"

    mail(:to => @to, :from => @from, :reply_to => @reply_to, :subject => subject)
  
  end

  def new_proyecto_vinculacion(service_request)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Coordinator
    @to << service_request.user.email

    @service_request = service_request
    @reply_to = service_request.supervisor.email

    subject = "Solicitud de Costeo del Proyecto #{service_request.number}: #{service_request.vinculacion_client_name}"

    mail(:to => @to, :from => @from, :reply_to => @reply_to, :subject => subject)
  
  end

  def costeo_enviado(service_request)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Coordinator
    @to << service_request.user.email

    # Vinculacion
    @to << service_request.supervisor.email

    @service_request = service_request
    @details = cost_details(@service_request)
    @reply_to = service_request.supervisor.email

    subject = "Costeo Enviado #{service_request.number}: #{service_request.vinculacion_client_name}"

    mail(:to => @to, :from => @from, :reply_to => @reply_to, :subject => subject)
  
  end

  def reporte_enviado(service_request)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Coordinator
    @to << service_request.user.email

    # Vinculacion
    @to << service_request.supervisor.email

    @service_request = service_request


    @participations = Array.new
    @service_request.service_request_participations.each do |p|

      @participations << {
        "nombre" => p.user.full_name,
        "email" => p.user.email,
        "porcentaje" => p.percentage
      }
      @to << p.user.email
    end

    @details = cost_details(@service_request)


    @reply_to = service_request.supervisor.email

    subject = "Reporte Enviado #{service_request.number}: #{service_request.vinculacion_client_name}"

    mail(:to => @to, :from => @from, :reply_to => @reply_to, :subject => subject)

  end


  def new_service_owner_auth(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Requestor  
    @to << requested_service.sample.service_request.user.email

    if requested_service.sample.service_request.user.require_auth?
      # Requestor supervisor 1 
      if !requested_service.sample.service_request.user.supervisor1.blank?
        @to << requested_service.sample.service_request.user.supervisor1.email
      end

      # Requestor supervisor 2 
      if !requested_service.sample.service_request.user.supervisor2.blank?
        @to << requested_service.sample.service_request.user.supervisor2.email
      end

      # Folder supervisor
      if !requested_service.sample.service_request.supervisor.blank?
        @to << requested_service.sample.service_request.supervisor.email
      end
    end

    @requested_service = requested_service

    subject = "Autorizar Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    mail(:to => @to, :from => @from, :subject => subject)
  
  end

  def new_service_sup_auth(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Requestor  
    @to << requested_service.sample.service_request.user.email

    if requested_service.sample.service_request.user.require_auth?
      # Requestor supervisor 1 
      if !requested_service.sample.service_request.user.supervisor1.blank?
        @to << requested_service.sample.service_request.user.supervisor1.email
      end

      # Requestor supervisor 2 
      if !requested_service.sample.service_request.user.supervisor2.blank?
        @to << requested_service.sample.service_request.user.supervisor2.email
      end

      # Folder supervisor
      if !requested_service.sample.service_request.supervisor.blank?
        @to << requested_service.sample.service_request.supervisor.email
      end
    end

    @requested_service = requested_service

    subject = "Autorizar Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def quote_needs_auth(requested_service_id, user_id)

    @requested_service = RequestedService.find(requested_service_id)

    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Lab Admins
    @requested_service.laboratory_service.laboratory.laboratory_members.where(:access => LaboratoryMember::ACCESS_ADMIN).each do |u|
      if user_id.to_i != u.user_id.to_i
        @to << u.user.email
      end
    end

    if @to.count == 0
      @to << @requested_service.user.email
    end 

    subject = "Autorizar Costeo del Servicio #{@requested_service.number}: #{@requested_service.laboratory_service.name}"

    mail(:to => @to, :from => @from, :subject => subject)
  end


  def status_change(requested_service, user, msgs)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Requestor  
    @to << requested_service.sample.service_request.user.email

    # Sender
    @to << user.email

    # Assigned
    if !requested_service.user.blank?
      @to << requested_service.user.email
    end

    if requested_service.status.to_i == RequestedService::INITIAL
      # Lab admin
      if !requested_service.laboratory_service.laboratory.user.blank?
        @to << requested_service.laboratory_service.laboratory.user.email
      end
    end

    # User Supervisors  
    if requested_service.status.to_i == RequestedService::REQ_SUP_AUTH   
      if !requested_service.sample.service_request.user.supervisor1.email.blank?
        @to << requested_service.sample.service_request.supervisor1.email
      end
      if !requested_service.sample.service_request.user.supervisor2.email.blank?
        @to << requested_service.sample.service_request.supervisor2.email
      end
    end

    # Folder supervisor
    # if !requested_service.sample.service_request.supervisor.blank?
    #  @to << requested_service.sample.service_request.supervisor.email
    # end

    @requested_service = requested_service
    @user = user
    @msgs = msgs

    subject = "[#{requested_service.number}] #{requested_service.status_text}"

    reply_to = user.email
    
    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  end

  def request_department_auth(service_request)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Department Supervisor  
    @to << service_request.user.department.user.email
    
    # Requestor
    reply_to = service_request.user.email

    @service_request = service_request
    @project_quote = @service_request.active_quote

    subject = "Costeo de Proyecto #{service_request.number}"

    

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)

  end


  def maintenance_reminder(m, subject)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Lab Admin
    @to << m.equipment.laboratory.user.email
    
    @maintenance = m

    @subject = subject

    mail(:to => @to, :from => @from, :subject => @subject)

  end




  # Si se actualiza el del controller se debe de actualizar aquí también. 
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
    requested_service.requested_service_technicians.each do |tech|
      technicians << {
        "detalle" => tech.user.full_name,
        "cantidad" => tech.hours,
        "precio_unitario" => tech.hourly_wage 
      }
    end

    # Equipment
    equipment = Array.new
    requested_service.requested_service_equipments.each do |eq|
      equipment << {
        "detalle" => eq.equipment.name,
        "cantidad" => eq.hours,
        "precio_unitario" => eq.hourly_rate
      }
    end


    # Others
    others = Array.new
    requested_service.requested_service_others.each do |ot|
      others << {
        "detalle" => "#{ot.other_type.name}: #{ot.concept}",
        "cantidad" => 1,
        "precio_unitario" => ot.price
      }
    end

    # Details
    details = {
      "bitacora_id"           => requested_service.id,
      "muestra_system_id"     => requested_service.sample.system_id,
      "muestra_identificador" => requested_service.sample.identification,
      "nombre_servicio"       => requested_service.laboratory_service.name,
      "personal"              => technicians,
      "equipos"               => equipment,
      "otros"                 => others
    }

    return details
  end


  


end
