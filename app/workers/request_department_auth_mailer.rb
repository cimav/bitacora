class RequestDepartmentAuthMailer
  @queue = :mail

  def self.perform(id)
    service_request = ServiceRequest.find(id)
    BitacoraMailer.request_department_auth(service_request).deliver 
  end

end