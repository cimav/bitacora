class NotifyNewCollaboratorMailer

  @queue = :mail

  def self.perform(service_request_id, collaborator_email)
    service_request = ServiceRequest.find(service_request_id)
    BitacoraMailer.notify_new_collaborator(service_request, collaborator_email).deliver
  end

end
