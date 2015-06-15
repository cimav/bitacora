# coding: utf-8
class BitacoraMailer < ActionMailer::Base
  default from: "bitacora.electronica@cimav.edu.mx"

  def new_service(requested_service)
  	@from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Requestor  
    @to << requested_service.sample.service_request.user.email
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    @requested_service = requested_service

    subject = "Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def new_tipo1(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Requestor  
    @to << requested_service.sample.service_request.user.email
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    @requested_service = requested_service

    subject = "Nuevo Servicio T1 #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def new_tipo2(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Requestor  
    @to << requested_service.sample.service_request.user.email
      
    # Lab admin
    if !requested_service.laboratory_service.laboratory.user.blank?
      @to << requested_service.laboratory_service.laboratory.user.email
    end
  
    # Suggested 
    if !requested_service.suggested_user.blank?
      @to << requested_service.suggested_user.email
    end

    @requested_service = requested_service

    subject = "Nuevo Servicio T2 #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
  end

  def new_tipo3(service_request)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

     # Coordinator
    @to << service_request.user.email

    @service_request = service_request
    @reply_to = service_request.supervisor.email

    subject = "Solicitud de Costeo #{service_request.number}: #{service_request.vinculacion_client_name}"

    mail(:to => @to, :from => @from, :reply_to => @reply_to, :subject => subject)
  
  end


  def new_service_owner_auth(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Requestor  
    @to << requested_service.sample.service_request.user.email

    if requested_service.sample.service_request.user.require_auth?
      # Requestor supervisor 1 
      if !requested_service.sample.service_request.user.supervisor1.blank?
        @to << requested_service.sample.service_request.user.supervisor1.email
      end

      # Requestor supervisor 2 
      if !requested_service.sample.service_request.user.supervisor2.blank?
        @to << requested_service.sample.service_request.user.supervisor2.email
      end

      # Folder supervisor
      if !requested_service.sample.service_request.supervisor.blank?
        @to << requested_service.sample.service_request.supervisor.email
      end
    end

    @requested_service = requested_service

    subject = "Autorizar Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    mail(:to => @to, :from => @from, :subject => subject)
  
  end

  def new_service_sup_auth(requested_service)
    @from = "Bitácora Electrónica <bitacora.electronica@cimav.edu.mx>"
    @to = []

    # Requestor  
    @to << requested_service.sample.service_request.user.email

    if requested_service.sample.service_request.user.require_auth?
      # Requestor supervisor 1 
      if !requested_service.sample.service_request.user.supervisor1.blank?
        @to << requested_service.sample.service_request.user.supervisor1.email
      end

      # Requestor supervisor 2 
      if !requested_service.sample.service_request.user.supervisor2.blank?
        @to << requested_service.sample.service_request.user.supervisor2.email
      end

      # Folder supervisor
      if !requested_service.sample.service_request.supervisor.blank?
        @to << requested_service.sample.service_request.supervisor.email
      end
    end

    @requested_service = requested_service

    subject = "Autorizar Nueva Solicitud #{requested_service.number}: #{requested_service.laboratory_service.name}"

    reply_to = requested_service.sample.service_request.user.email

    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  
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

    if requested_service.status.to_i == RequestedService::INITIAL
      # Lab admin
      if !requested_service.laboratory_service.laboratory.user.blank?
        @to << requested_service.laboratory_service.laboratory.user.email
      end
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

    subject = "[#{requested_service.number}] #{requested_service.status_text}"

    reply_to = user.email
    
    mail(:to => @to, :from => @from, :reply_to => reply_to, :subject => subject)
  end

end
