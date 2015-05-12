class VinculacionSubscriptions
  include QueueBus::Subscriber

  subscribe :solicitar_costeo 
  subscribe :notificar_arranque
  subscribe :notificar_arranque_no_coordinado
  subscribe :notificar_arranque_tipo_2
  subscribe :notificar_cancelacion
  
  def solicitar_costeo(attributes)

    # Create service_request
    puts "Solicitar Costeo #{attributes['costeo_id']}: #{attributes['codigo']}"
    if u_requestor = User.where(:email => attributes['empleado_email']).first
      folder = u_requestor.service_request.new 
      folder.system_id         = attributes['id']
      folder.system_request_id = attributes['solicitud_id']
      folder.request_type_id   = 1  # ID servicio vinculacion     
      folder.request_link      = attributes['nombre']
      folder.number            = attributes['codigo']
      folder.description       = attributes['descripcion']
      folder.vinculacion_client_id   = attributes['cliente_id']
      folder.vinculacion_client_name = attributes['cliente_nombre']
      folder.system_status     = ServiceRequest::SYSTEM_TO_QUOTE
      if u_supervisor = User.where(:email => attributes['agente_email']).first
        folder.supervisor_id = u_supervisor.id
      else
        folder.supervisor_id = u_requestor.id
      end
      folder.save(:validate => false)

      # Add samples to service_request   
      attributes['muestras'].each do |m|
        puts "Agregar muestra #{m['identificacion']} (costeo #{attributes['costeo_id']})"
        muestra = folder.sample.new
        muestra.system_id      = m['id']
        muestra.identification = m['identificacion']
        muestra.description    = m['descripcion']
        muestra.quantity       = m['cantidad']
        muestra.save
      end
    end
  end

  def notificar_arranque(attributes)
    puts "Arranque de la solicitud coordinada #{attributes['solicitud_id']}"
    if services = ServiceRequest.where(:system_request_id => attributes['solicitud_id'])
      services.each do |s|    
        # TODO: validar agente
        s.system_status = ServiceRequest::SYSTEM_ACCEPTED
        s.vinculacion_start_date  = attributes['fecha_inicio']
        s.vinculacion_end_date    = attributes['fecha_termino']
        s.vinculacion_days        = attributes['duracion']
        s.vinculacion_delivery    = attributes['tiempo_entrega']
        if s.save
          puts "Iniciado el folder #{s.id}"
          s.requested_services.each do |rs|
            puts "Iniciado el servicio #{rs.id}"
            rs.status = RequestedService::INITIAL
            rs.save
          end
        else 
          puts "Error al guardar service_request"
        end
      end
    else
      puts "Servicio no encontrado"
    end
  end

  def notificar_arranque_no_coordinado(attributes)
    puts "Arranque de la solicitud #{attributes['solicitud_id']}"

    # Create service_request
    puts "Crear carpeta #{attributes['codigo']}"
    if u_requestor = User.where(:email => attributes['agente_email']).first
      folder = u_requestor.service_request.new 
      folder.system_id               = attributes['id']
      folder.system_request_id       = attributes['solicitud_id']
      folder.request_type_id         = ServiceRequest::SERVICIO_VINCULACION_NO_COORDINADO
      folder.request_link            = attributes['descripcion']     # Descripción de la solicitud
      folder.number                  = attributes['carpeta_codigo']
      folder.description             = attributes['nombre']          # Nombre del servicio solicitado
      folder.vinculacion_client_id   = attributes['cliente_id']
      folder.vinculacion_client_name = attributes['cliente_nombre']
      folder.vinculacion_start_date  = attributes['fecha_inicio']
      folder.vinculacion_end_date    = attributes['fecha_termino']
      folder.vinculacion_days        = attributes['duracion']
      folder.vinculacion_delivery    = attributes['tiempo_entrega']
      folder.system_status           = ServiceRequest::SYSTEM_FREE
      folder.save(:validate => false)

      # Add samples to service_request  
      m = attributes['muestra'] 
      puts "Agregar muestra #{m['identificacion']}"
      muestra = folder.sample.new
      muestra.system_id      = m['id']
      muestra.identification = m['identificacion']
      muestra.description    = m['descripcion']
      muestra.quantity       = m['cantidad']
      muestra.save

      if lab_service = LaboratoryService.find(attributes['servicio_bitacora_id'])
        requested_service = RequestedService.new
        requested_service.laboratory_service_id = lab_service.id
        requested_service.sample_id = muestra.id
        requested_service.details = attributes['descripcion']
        # TODO:
        # requested_service.suggested_user_id = lab_service.default_user_id
        requested_service.status = RequestedService::INITIAL
        requested_service.save(:validate => false) 
      end
      
    end

  end

  def notificar_arranque_tipo_2(attributes)
    puts "Arranque Tipo 2 de la solicitud #{attributes['solicitud_id']}"

    # Create service_request
    puts "Crear carpeta #{attributes['codigo']}"
    if u_requestor = User.where(:email => attributes['responsable_email']).first
      folder = u_requestor.service_request.new 
      folder.system_id               = attributes['id']
      folder.system_request_id       = attributes['solicitud_id']
      folder.request_type_id         = ServiceRequest::SERVICIO_VINCULACION_TIPO_2
      folder.request_link            = attributes['descripcion']     # Descripción de la solicitud
      folder.number                  = attributes['carpeta_codigo']
      folder.description             = attributes['nombre']          # Nombre del servicio solicitado
      folder.vinculacion_client_id   = attributes['cliente_id']
      folder.vinculacion_client_name = attributes['cliente_nombre']
      folder.vinculacion_start_date  = attributes['fecha_inicio']
      folder.vinculacion_end_date    = attributes['fecha_termino']
      folder.vinculacion_days        = attributes['duracion']
      folder.vinculacion_delivery    = attributes['tiempo_entrega']
      folder.system_status           = ServiceRequest::SYSTEM_FREE
      if u_supervisor = User.where(:email => attributes['agente_email']).first
        folder.supervisor_id = u_supervisor.id
      else
        folder.supervisor_id = u_requestor.id
      end
      folder.save(:validate => false)

      # Add samples to service_request
      attributes['muestras'].each do |m|  
        puts "Agregar muestra #{m['identificacion']}"
        muestra = folder.sample.new
        muestra.system_id      = m['id']
        muestra.number         = m['codigo']
        muestra.identification = m['identificacion']
        muestra.description    = m['descripcion']
        muestra.quantity       = m['cantidad']
        muestra.save
      end

      # Add services 
      attributes['servicios'].each do |s|
        puts "Agregar servicio #{s['nombre']} a #{s['muestra_codigo']}"
        if muestra = Sample.where(:number => s['muestra_codigo']).first
          if lab_service = LaboratoryService.find(s['servicio_bitacora_id'])
            requested_service = RequestedService.new
            requested_service.laboratory_service_id = lab_service.id
            requested_service.sample_id = muestra.id
            requested_service.details = s['nombre']
            # TODO:
            # requested_service.suggested_user_id = lab_service.default_user_id
            requested_service.status = RequestedService::INITIAL
            requested_service.save(:validate => false) 
          end
        end
      end


    #   if lab_service = LaboratoryService.find(attributes['servicio_bitacora_id'])
    #     requested_service = RequestedService.new
    #     requested_service.laboratory_service_id = lab_service.id
    #     requested_service.sample_id = muestra.id
    #     requested_service.details = attributes['descripcion']
    #     # TODO:
    #     # requested_service.suggested_user_id = lab_service.default_user_id
    #     requested_service.status = RequestedService::INITIAL
    #     requested_service.save(:validate => false) 
    #   end
      
    end

  end



  def notificar_cancelacion(attributes)
    puts "Cancelar solicitud #{attributes['solicitud_id']}"
    if services = ServiceRequest.where(:system_request_id => attributes['solicitud_id'])
      services.each do |s|    
        # TODO: validar agente
        s.system_status = ServiceRequest::SYSTEM_CANCELED
        if s.save
          puts "Cancelado el folder #{s.id}"
          s.requested_services.each do |rs|
            puts "Cancelando el servicio #{rs.id}"
            rs.status = RequestedService::CANCELED
            rs.save
          end
        else 
          puts "Error al guardar service_request"
        end
      end
    else
      puts "Servicio no encontrado"
    end
  end

end
