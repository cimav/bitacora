class StatusChangeMailer
  @queue = :mail

  def self.perform(requested_service_id, user_id, msgs)
    requested_service = RequestedService.find(requested_service_id)
    user = User.find(user_id)
    BitacoraMailer.status_change(requested_service, user, msgs).deliver 
  end

end