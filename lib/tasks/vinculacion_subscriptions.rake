class VinculacionSubscriptions
  include ResqueBus::Subscriber

  subscribe :solicitar_costeo

  def solicitar_costeo(attributes)

    # Create service_request
    puts "Solicitar Costeo #{attributes['costeo_id']}: #{attributes['codigo']}"
    if u_requestor = User.where(:email => attributes['empleado_email']).first
      folder = u_requestor.service_request.new 
      folder.system_id       = attributes['id']
      folder.request_type_id = 1  # ID servicio vinculacion     
      folder.request_link    = attributes['nombre']
      folder.number          = attributes['codigo']
      folder.description     = attributes['descripcion']
      folder.system_status   = ServiceRequest::SYSTEM_TO_QUOTE
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
    if service = ServiceRequest.find(:system_id => attributes['id'])
      # TODO: validar agente
      service.status = ServiceRequest::SYSTEM_ACCEPTED
      service.save
    else
      puts "Servicio no encontrado"
    end
  end

  def notificar_cancelacion(attributes)
    if service = ServiceRequest.find(:system_id => attributes['id'])
      # TODO: validar agente
      service.status = ServiceRequest::SYSTEM_CANCELED
      service.save
    else
      puts "Servicio no encontrado"
    end
  end

end
