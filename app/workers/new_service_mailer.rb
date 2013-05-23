class NewServiceMailer
  @queue = :mail

  def self.perform(requested_service_id)
    requested_service = RequestedService.find(requested_service_id)
    BitacoraMailer.new_service(requested_service).deliver 
  end

end
