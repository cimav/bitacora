class NewProyectoVinculacionMailer
  @queue = :mail

  def self.perform(service_request_id)
    service_request = ServiceRequest.find(service_request_id)
    BitacoraMailer.new_proyecto_vinculacion(service_request).deliver 
  end

end