class VinculacionSubscriptions
  include QueueBus::Subscriber

  subscribe :solicitar_costeo 
  subscribe :notificar_arranque
  subscribe :notificar_arranque_no_coordinado
  subscribe :notificar_arranque_tipo_2
  subscribe :notificar_cancelacion
  subscribe :cancelar_servicio_solicitado
  
  # COSTEO TIPO 3 y Proyectos
  def solicitar_costeo(attributes)

    # Create service_request
    puts " LOG Solicitar Costeo #{attributes['costeo_id']}: #{attributes['codigo']}"
    if u_requestor = User.where(:email => attributes['empleado_email']).first

      folder = u_requestor.service_request.new 
      folder.system_id                   = attributes['id']
      folder.system_request_id           = attributes['solicitud_id']
      
      if (attributes['tipo'] == 3)
        folder.request_type_id           = ServiceRequest::SERVICIO_VINCULACION
      end
      if (attributes['tipo'] == 4)
        folder.request_type_id           = ServiceRequest::PROYECTO_VINCULACION
      end
      puts " LOG Tipo: #{folder.request_type_id}"
      
      folder.request_link                = attributes['nombre']
      folder.number                      = attributes['codigo']
      folder.description                 = attributes['descripcion']
      folder.vinculacion_client_id       = attributes['cliente_id']
      folder.vinculacion_client_name     = attributes['cliente_nombre']
      folder.vinculacion_client_contact  = attributes['cliente_contacto']
      folder.vinculacion_client_phone    = attributes['cliente_telefono']
      folder.vinculacion_client_email    = attributes['cliente_email']
      folder.vinculacion_client_address1 = attributes['cliente_calle']
      folder.vinculacion_client_address2 = attributes['cliente_colonia']
      folder.vinculacion_client_city     = attributes['cliente_ciudad']
      folder.vinculacion_client_state    = attributes['cliente_estado']
      folder.vinculacion_client_country  = attributes['cliente_pais']
      folder.vinculacion_client_zip      = attributes['cliente_cp']
      folder.vinculacion_hash            = attributes['vinculacion_hash']

      folder.system_status     = ServiceRequest::SYSTEM_TO_QUOTE
      puts " LOG Status: #{folder.system_status}"
      if u_supervisor = User.where(:email => attributes['agente_email']).first
        folder.supervisor_id = u_supervisor.id
        puts " LOG Es agente"
      else
        folder.supervisor_id = u_requestor.id
        puts " LOG Es requisitor"
      end
      puts " LOG Supervisor: #{folder.supervisor_id}"
      folder.save(:validate => false)
      puts " LOG Si guardo folder"


      # Add samples to service_request
      attributes['muestras'].each do |m|  
        puts " LOG Agregar muestra #{m['muestra']['identificacion']} (costeo #{attributes['costeo_id']})"
        muestra = folder.sample.new
        muestra.system_id      = m['muestra']['id']
        muestra.number         = m['muestra']['codigo']
        muestra.identification = m['muestra']['identificacion']
        muestra.description    = m['muestra']['descripcion']
        muestra.quantity       = m['muestra']['cantidad']
        muestra.save
        m['detalles'].each do |md|
          puts " LOG Agregar detalles de muestra #{md['consecutivo']}"
          sd = muestra.sample_details.new
          sd.consecutive = md['consecutivo']
          sd.client_identification = md['cliente_identificacion']
          sd.notes = md['notas']
          sd.save
        end
      end

      if (attributes['tipo'] == 3)
        Resque.enqueue(NewTipo3Mailer, folder.id)
      end

      if (attributes['tipo'] == 4)
        Resque.enqueue(NewProyectoVinculacionMailer, folder.id)
      end

    end
  end


  # ARRANQUE TIPO 3
  def notificar_arranque(attributes)
    puts " LOG Arranque de la solicitud coordinada #{attributes['solicitud_id']}"
    Rails.logger.debug attributes
    if services = ServiceRequest.where(:system_request_id => attributes['solicitud_id']).where.not(:system_status => ServiceRequest::SYSTEM_CANCELED)
      services.each do |s|    
        # TODO: validar agente
        puts " LOG DURACION: #{attributes['duracion']}"
        s.system_status = ServiceRequest::SYSTEM_ACCEPTED
        s.vinculacion_start_date  = attributes['fecha_inicio']
        s.vinculacion_end_date    = attributes['fecha_termino']
        s.vinculacion_days        = attributes['duracion']
        s.vinculacion_delivery    = attributes['tiempo_entrega']
        
        # Update sample details
        puts " LOG Actualiza muestras"
        attributes['muestras'].each do |m|
          puts " LOG Actualizando muestra #{m['muestra']['id']}"
          Rails.logger.debug m
          if muestra = s.sample.find_by(:system_id => m['muestra']['id'])
            muestra.number         = m['muestra']['codigo']
            muestra.identification = m['muestra']['identificacion']
            muestra.description    = m['muestra']['descripcion']
            muestra.quantity       = m['muestra']['cantidad']
            muestra.save
            puts " LOG Borrar detalles anteriores"
            muestra.sample_details.destroy_all
            puts " LOG Poner nuevos detalles"
            m['detalles'].each do |md|
              puts " LOG Actualizar detalles de muestra #{md['consecutivo']}"
              Rails.logger.debug md
              sd = muestra.sample_details.new
              sd.consecutive = md['consecutivo']
              sd.client_identification = md['cliente_identificacion']
              sd.notes = md['notas']
              sd.save
            end
          end
        end

        if s.save
          puts " LOG Iniciado el folder #{s.id}"
          s.requested_services.each do |rs|
            if rs.status.to_i != RequestedService::CANCELED  && rs.status.to_i != RequestedService::DELETED 
              puts " LOG Iniciado el servicio #{rs.id}"
              rs.status = RequestedService::INITIAL
              rs.save
            end
          end
        else 
          puts " LOG Error al guardar service_request"
        end
      end
    else
      puts " LOG Servicio no encontrado"
    end
  end


  # ARRANQUE TIPO 1
  def notificar_arranque_no_coordinado(attributes)
    puts " LOG Arranque de la solicitud #{attributes['solicitud_id']}"

    # Create service_request
    puts " LOG Crear carpeta #{attributes['codigo']}"
    if u_requestor = User.where(:email => attributes['agente_email']).first
      folder = u_requestor.service_request.new 
      folder.system_id                   = attributes['id']
      folder.system_request_id           = attributes['solicitud_id']
      folder.request_type_id             = ServiceRequest::SERVICIO_VINCULACION_NO_COORDINADO
      folder.request_link                = attributes['descripcion']     # Descripción de la solicitud
      folder.number                      = attributes['carpeta_codigo']
      folder.description                 = attributes['nombre']          # Nombre del servicio solicitado
      folder.vinculacion_client_id       = attributes['cliente_id']
      folder.vinculacion_client_name     = attributes['cliente_nombre']
      folder.vinculacion_client_contact  = attributes['cliente_contacto']
      folder.vinculacion_client_email    = attributes['cliente_email']
      folder.vinculacion_client_phone    = attributes['cliente_telefono']
      folder.vinculacion_client_address1 = attributes['cliente_calle']
      folder.vinculacion_client_address2 = attributes['cliente_colonia']
      folder.vinculacion_client_city     = attributes['cliente_ciudad']
      folder.vinculacion_client_state    = attributes['cliente_estado']
      folder.vinculacion_client_country  = attributes['cliente_pais']
      folder.vinculacion_client_zip      = attributes['cliente_cp']
      folder.vinculacion_hash            = attributes['vinculacion_hash']

      folder.vinculacion_start_date      = attributes['fecha_inicio']
      folder.vinculacion_end_date        = attributes['fecha_termino']
      folder.vinculacion_days            = attributes['duracion']
      folder.vinculacion_delivery        = attributes['tiempo_entrega']
      folder.system_status               = ServiceRequest::SYSTEM_FREE
      folder.save(:validate => false)

      # Add samples to service_request  
      m = attributes['muestra'] 
      puts " LOG Agregar muestra #{m['identificacion']}"
      muestra = folder.sample.new
      muestra.system_id      = m['id']
      muestra.identification = m['identificacion']
      muestra.description    = m['descripcion']
      muestra.quantity       = m['cantidad']
      muestra.save

      # Add details to sample
      attributes['muestra_detalles'].each do |md|
        puts " LOG Agregar detalles de muestra #{md['consecutivo']}"
        sd = muestra.sample_details.new
        sd.consecutive = md['consecutivo']
        sd.client_identification = md['cliente_identificacion']
        sd.notes = md['notas']
        sd.save
      end

      if lab_service = LaboratoryService.find(attributes['servicio_bitacora_id'])
        requested_service = RequestedService.new
        requested_service.laboratory_service_id = lab_service.id
        requested_service.sample_id = muestra.id
        requested_service.details = attributes['descripcion']
        # TODO:
        # requested_service.suggested_user_id = lab_service.default_user_id
        requested_service.status = RequestedService::INITIAL
        requested_service.save(:validate => false) 
        Resque.enqueue(NewTipo1Mailer, requested_service.id)
      end
      
    end

  end


  # ARRANQUE TIPO 2
  def notificar_arranque_tipo_2(attributes)

    puts " LOG Arranque Tipo 2 de la solicitud #{attributes['solicitud_id']}"

    # Create service_request
    puts " LOG Crear carpeta #{attributes['carpeta_codigo']}"
    if u_requestor = User.where(:email => attributes['responsable_email']).first
      folder = u_requestor.service_request.new 
      folder.system_id                   = attributes['id']
      folder.system_request_id           = attributes['solicitud_id']
      folder.request_type_id             = ServiceRequest::SERVICIO_VINCULACION_TIPO_2
      folder.request_link                = attributes['descripcion']     # Descripción de la solicitud
      folder.number                      = attributes['carpeta_codigo']
      folder.description                 = attributes['nombre']          # Nombre del servicio solicitado
      folder.vinculacion_client_id       = attributes['cliente_id']
      folder.vinculacion_client_name     = attributes['cliente_nombre']
      folder.vinculacion_client_contact  = attributes['cliente_contacto']
      folder.vinculacion_client_email    = attributes['cliente_email']
      folder.vinculacion_client_phone    = attributes['cliente_telefono']
      folder.vinculacion_client_address1 = attributes['cliente_calle']
      folder.vinculacion_client_address2 = attributes['cliente_colonia']
      folder.vinculacion_client_city     = attributes['cliente_ciudad']
      folder.vinculacion_client_state    = attributes['cliente_estado']
      folder.vinculacion_client_country  = attributes['cliente_pais']
      folder.vinculacion_client_zip      = attributes['cliente_cp']
      folder.vinculacion_hash            = attributes['vinculacion_hash']
      
      folder.vinculacion_start_date      = attributes['fecha_inicio']
      folder.vinculacion_end_date        = attributes['fecha_termino']
      folder.vinculacion_days            = attributes['duracion']
      folder.vinculacion_delivery        = attributes['tiempo_entrega']
      folder.system_status               = ServiceRequest::SYSTEM_ACCEPTED
      if u_supervisor = User.where(:email => attributes['agente_email']).first
        folder.supervisor_id = u_supervisor.id
      else
        folder.supervisor_id = u_requestor.id
      end
      folder.save(:validate => false)

      # Add samples to service_request
      attributes['muestras'].each do |m|  
        puts " LOG Agregar muestra #{m['muestra']['identificacion']}"
        muestra = folder.sample.new
        muestra.system_id      = m['muestra']['id']
        muestra.number         = m['muestra']['codigo']
        muestra.identification = m['muestra']['identificacion']
        muestra.description    = m['muestra']['descripcion']
        muestra.quantity       = m['muestra']['cantidad']
        muestra.save
        m['detalles'].each do |md|
          puts " LOG Agregar detalles de muestra #{md['consecutivo']}"
          sd = muestra.sample_details.new
          sd.consecutive = md['consecutivo']
          sd.client_identification = md['cliente_identificacion']
          sd.notes = md['notas']
          sd.save
        end
      end

      # Add services 
      attributes['servicios'].each do |s|
        puts " LOG Agregar servicio #{s['nombre']} a #{s['muestra_codigo']}"
        if muestra = Sample.where(:number => s['muestra_codigo']).first
          if lab_service = LaboratoryService.find(s['servicio_bitacora_id'])
            requested_service = RequestedService.new
            requested_service.laboratory_service_id = lab_service.id
            requested_service.sample_id = muestra.id
            requested_service.details = s['nombre']
            requested_service.cedula_id = s['cedula_id']
            # TODO:
            # requested_service.suggested_user_id = lab_service.default_user_id
            requested_service.status = RequestedService::INITIAL
            requested_service.save(:validate => false) 
            Resque.enqueue(NewTipo2Mailer, requested_service.id)
          end
        end
      end

    end

  end



  def notificar_cancelacion(attributes)
    puts " LOG Cancelar solicitud #{attributes['solicitud_id']}"
    if services = ServiceRequest.where(:system_request_id => attributes['solicitud_id'])
      services.each do |s|    
        # TODO: validar agente
        s.system_status = ServiceRequest::SYSTEM_CANCELED
        if s.save
          puts " LOG Cancelado el folder #{s.id}"
          s.requested_services.each do |rs|
            puts " LOG Cancelando el servicio #{rs.id}"
            rs.status = RequestedService::CANCELED
            rs.save
            if u_agente = User.where(:email => attributes['agente_email']).first
              rs.activity_log.create(user_id: u_agente.id,
                                     service_request_id: rs.sample.service_request_id,
                                     sample_id: rs.sample_id,
                                     message_type: 'CANCELED',
                                     requested_service_status: RequestedService::CANCELED,
                                     message: "Se ha cancelado el servicio")
            end
          end
        else 
          puts " LOG Error al guardar service_request"
        end
      end
    else
      puts " LOG Servicio no encontrado"
    end
  end

  def cancelar_servicio_solicitado(attributes)
    puts " LOG Cancelar servicio #{attributes['servicio_id']} de la solicitud #{attributes['solicitud_id']}"
    if services = ServiceRequest.where(:system_id => attributes['id'])
      services.each do |s|    
        # TODO: validar agente
        s.system_status = ServiceRequest::SYSTEM_CANCELED
        if s.save
          puts " LOG Cancelado el folder #{s.id}"
          s.requested_services.each do |rs|
            puts " LOG Cancelando el servicio #{rs.id}"
            rs.status = RequestedService::CANCELED
            rs.save
            if u_agente = User.where(:email => attributes['agente_email']).first
              rs.activity_log.create(user_id: u_agente.id,
                                     service_request_id: rs.sample.service_request_id,
                                     sample_id: rs.sample_id,
                                     message_type: 'CANCELED',
                                     requested_service_status: RequestedService::CANCELED,
                                     message: "Se ha cancelado el servicio")
            end
          end
        else 
          puts " LOG Error al guardar service_request"
        end
      end
    else
      puts " LOG Servicio no encontrado"
    end
  end

end
