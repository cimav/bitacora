class SolicitarPresupuestoMailer
  @queue = :mail

  def self.perform(service_request_id)
    service_request = ServiceRequest.find(service_request_id)
    BitacoraMailer.solicitar_presupuesto(service_request).deliver
  end

end
