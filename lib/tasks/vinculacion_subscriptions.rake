class VinculacionSubscriptions
  include ResqueBus::Subscriber

  subscribe :solicitar_costeo 
  subscribe :notificar_arranque
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
    puts "Arranque de la solicitud #{attributes['solicitud_id']}"
    if services = ServiceRequest.where(:system_request_id => attributes['solicitud_id'])
      services.each do |s|    
        # TODO: validar agente
        s.system_status = ServiceRequest::SYSTEM_ACCEPTED
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
