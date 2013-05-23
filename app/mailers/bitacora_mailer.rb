# coding: utf-8
class BitacoraMailer < ActionMailer::Base
  default from: "bitacora.electronica@cimav.edu.mx"

  def new_service(requested_service)
  	@from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []
      
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    if !requested_service.sample.service_request.supervisor.blank?
      @to << requested_service.sample.service_request.supervisor.email
    end

    @requested_service = requested_service

    subject = "Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    mail(:to => @to, :from => @from, :subject => subject)
  
  end

end
