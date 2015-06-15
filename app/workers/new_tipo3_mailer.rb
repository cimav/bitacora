class NewTipo3Mailer
  @queue = :mail

  def self.perform(service_request_id)
    service_request = ServiceRequest.find(service_request_id)
    BitacoraMailer.new_tipo3(service_request).deliver 
  end

end