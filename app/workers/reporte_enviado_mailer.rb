class ReporteEnviadoMailer
  @queue = :mail

  def self.perform(service_request_id)
    service_request = ServiceRequest.find(service_request_id)
    BitacoraMailer.reporte_enviado(service_request).deliver 
  end

end