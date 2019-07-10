class ArrancarTipo3Mailer
  @queue = :mail

  def self.perform(service_request_id)
    service_request = ServiceRequest.find(service_request_id)
    BitacoraMailer.arrancar_tipo3(service_request).deliver
  end

end