# coding: utf-8
class BitacoraMailer < ActionMailer::Base
  default from: "bitacora.electronica@cimav.edu.mx"

  def new_service(requested_service)
  	@from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    # Folder supervisor
    # if !requested_service.sample.service_request.supervisor.blank?
    #  @to << requested_service.sample.service_request.supervisor.email
    # end

    @requested_service = requested_service

    subject = "Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    mail(:to => @to, :from => @from, :subject => subject)
  
  end

  def status_change(requested_service, user, msgs)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Requestor  
    @to << requested_service.sample.service_request.user.email

    # Sender
    @to << user.email

    # Assigned
    if !requested_service.user.blank?
      @to << requested_service.user.email
    end

    # User Supervisors  
    if requested_service.status.to_i == RequestedService::REQ_SUP_AUTH   
      if !requested_service.sample.service_request.user.supervisor1.email.blank?
        @to << requested_service.sample.service_request.supervisor1.email
      end
      if !requested_service.sample.service_request.user.supervisor2.email.blank?
        @to << requested_service.sample.service_request.supervisor2.email
      end
    end

    # Folder supervisor
    # if !requested_service.sample.service_request.supervisor.blank?
    #  @to << requested_service.sample.service_request.supervisor.email
    # end

    @requested_service = requested_service
    @user = user
    @msgs = msgs

    subject = "#{requested_service.status_text} / Servicio #{requested_service.number}: #{requested_service.laboratory_service.name}"

    mail(:to => @to, :from => @from, :subject => subject)
  end

end
