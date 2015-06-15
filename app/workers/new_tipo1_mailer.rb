class NewTipo1Mailer
  @queue = :mail

  def self.perform(requested_service_id)
    requested_service = RequestedService.find(requested_service_id)
    BitacoraMailer.new_tipo1(requested_service).deliver 
  end

end
