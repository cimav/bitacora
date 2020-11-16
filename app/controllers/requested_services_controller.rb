# coding: utf-8
require 'resque-bus'
class RequestedServicesController < ApplicationController
  before_filter :auth_required, :except => [:survey, :return_to_lab]
  respond_to :html, :json

  def initial_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def sup_auth_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def owner_auth_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def deliver_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end
 
  def receive_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def assign_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def suspend_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def reinit_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def start_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def finish_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def cancel_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def delete_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def send_quote_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def return_quote_dialog
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def get_grand_total(id)
    grand_total = RequestedService.find_by_sql(["SELECT IFNULL(SUM(subtotal),0) AS total FROM (
                                                   SELECT SUM(hours * hourly_rate) AS subtotal 
                                                     FROM requested_service_equipments 
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id 
                                                   UNION 
                                                     SELECT SUM(hours * hourly_wage) AS subtotal 
                                                     FROM requested_service_technicians 
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id
                                                   UNION
                                                     SELECT SUM(price) AS subtotal 
                                                     FROM requested_service_others 
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id
                                                 ) subtotals", :requested_service => id]).first.total
  end

  def grand_total
    @grand_total = get_grand_total(params[:id])
    render :layout => false
  end

  def lab_view 
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def show
    @requested_service = RequestedService.find(params['id'])

    if (@requested_service.status.to_i != RequestedService::DELETED)
      @activity_log = ActivityLog.where(" (service_request_id = :service_request AND sample_id = 0 AND requested_service_id = 0)
                                        OR (service_request_id = :service_request AND sample_id = :sample AND requested_service_id = 0)
                                        OR (service_request_id = :service_request AND sample_id = :sample AND requested_service_id = :requested_service)
                                    ", {:service_request => @requested_service.sample.service_request.id,
                                        :sample => @requested_service.sample_id,
                                        :requested_service => @requested_service.id
                                       }).order('created_at DESC')
      @grand_total = get_grand_total(params['id'])
      render :layout => false
    else 
      render :inline => '<div class="sheet"><div class="app-message">Servicio Eliminado</div></div>'.html_safe  
    end
  end

  def survey 
    @survey = RequestedServiceSurvey.where(:token => params[:token]).first
    @requested_service = @survey.requested_service

    if @requested_service.status.to_i == RequestedService::CONFIRMED
      @show_survey = "true"
    else
      @show_survey = "false"
    end

    if @requested_service.status.to_i != RequestedService::FINISHED && @requested_service.status.to_i != RequestedService::CONFIRMED
      redirect_to '/'
    else 
      render :layout => 'standalone'
    end
    
  end

  def save_survey
    @survey = RequestedServiceSurvey.where(:token => params[:token]).first
    
    @survey.q1 = params[:q1]
    @survey.q2 = params[:q2]
    @survey.q3 = params[:q3]
    @survey.q4 = params[:q4]
    @survey.q5 = params[:q5]
    @survey.save

    @requested_service = @survey.requested_service
    @requested_service.status = RequestedService::CONFIRMED
    @requested_service.save
    render :layout => 'standalone'
  end

  def create

    # TODO: No permitir crear servicios en carpetas tipo vinculación (en la UI ya no se muestra botón)
    
    if params[:requested_service][:from_id] == 'false'
      params[:requested_service][:from_id] = nil
      if current_user.require_auth?
        params[:requested_service][:status] = RequestedService::REQ_SUP_AUTH
      else
        params[:requested_service][:status] = RequestedService::INITIAL
      end
    else
      from_rq = RequestedService.find(params[:requested_service][:from_id])
      if from_rq
        if (from_rq.sample.service_request.user_id == current_user.id)
          params[:requested_service][:status] = RequestedService::INITIAL
          params[:requested_service][:from_id] = nil
        else
          params[:requested_service][:status] = RequestedService::REQ_OWNER_AUTH
        end
      else
        params[:requested_service][:from_id] = nil
      end
    end


    
    @requested_service = RequestedService.new(params[:requested_service])
    flash = {}
    if @requested_service.save
      flash[:notice] = "Servicio agregado."

      # LOG
      if (@requested_service.from_id.to_i > 0)
        @requested_service.activity_log.create(user_id: current_user.id,
                                               service_request_id: @requested_service.sample.service_request_id,
                                               sample_id: @requested_service.sample_id,
                                               message_type: 'CREATE',
                                               requested_service_status: RequestedService::REQ_OWNER_AUTH,
                                               message: "#{@requested_service.laboratory_service.name} agregado a la muestra #{@requested_service.sample.number}, se requiere autorización por parte del dueño.")
        # Sent mail to owner
        Resque.enqueue(NewServiceOwnerAuthMailer, @requested_service.id)
      elsif current_user.require_auth?
        @requested_service.activity_log.create(user_id: current_user.id,
                                               service_request_id: @requested_service.sample.service_request_id,
                                               sample_id: @requested_service.sample_id,
                                               message_type: 'CREATE',
                                               requested_service_status: RequestedService::REQ_SUP_AUTH,
                                               message: "#{@requested_service.laboratory_service.name} agregado a la muestra #{@requested_service.sample.number}, se requiere autorización por parte del supervisor")
        # Sent mail to involved
        Resque.enqueue(NewServiceSupAuthMailer, @requested_service.id)
      else
        @requested_service.activity_log.create(user_id: current_user.id,
                                               service_request_id: @requested_service.sample.service_request_id,
                                               sample_id: @requested_service.sample_id,
                                               message_type: 'CREATE',
                                               requested_service_status: RequestedService::INITIAL,
                                               message: "#{@requested_service.laboratory_service.name} agregado a la muestra #{@requested_service.sample.number}")
        # Sent mail to involved
        Resque.enqueue(NewServiceMailer, @requested_service.id)
      end

      # FOLDER STATUS
      set_folder_status(@requested_service.sample.service_request)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:service_request_id] = @requested_service.sample.service_request_id
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            
            if (@requested_service.from_id.to_i > 0) 
              json[:from_lab] = true
              json[:lab_view] = true
              json[:from_id] = @requested_service.from_id
            else
              json[:from_lab] = false
              json[:lab_view] = false
            end

            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end
    else
      flash[:error] = "Error al crear muestra."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end
  end

  def return_to_lab
    @survey = RequestedServiceSurvey.where(:token => params[:token]).first
    @requested_service = @survey.requested_service
    @requested_service.status = RequestedService::RETURNED
    @requested_service.results_date = nil
    @requested_service.finished_date = nil
    @requested_service.save
    msg = "El servicio #{@requested_service.number} ha sido regresado al laboratorio por el solicitante" 
    prv_msg = []
    prv_msg << {:status => "STATUS", :msg => "#{msg}"}
    if !params[:msg].blank?
      msg = params[:msg]
      prv_msg << {:status => "USER", :msg => "#{msg}"}
    end
    prv_msg.each do |item|
      @requested_service.activity_log.create(user_id:  @requested_service.sample.service_request.user_id,
                                           service_request_id: @requested_service.sample.service_request_id,
                                           sample_id: @requested_service.sample_id,
                                           message_type: "#{item[:status]}",
                                           requested_service_status: @requested_service.status,
                                           message: "#{item[:msg]}.")
    end
    # Sent mail to involved
    Resque.enqueue(StatusChangeMailer, @requested_service.id, current_user.id, prv_msg)
    respond_with do |format|
      format.html do
        if request.xhr?
          json = {}
          json[:msg] = msg
          render :json => json
        else
          redirect_to @requested_service
        end
      end
    end
  end

  def update
    @requested_service = RequestedService.find(params[:id])

    flash = {}
    prev_status = @requested_service.status
    params[:requested_service].delete(:user_id) if params[:requested_service][:user_id] == '-'
    if @requested_service.update_attributes(params[:requested_service])
      flash[:notice] = "Servicio actualizado"
      msg = @requested_service.status


      if prev_status != @requested_service.status.to_i

        prv_msg = []
        if prev_status.to_i == RequestedService::INITIAL
          if @requested_service.status.to_i == RequestedService::ASSIGNED
            prv_msg << {:status => RequestedService::RECEIVED, :msg => "Muestra para el servicio #{@requested_service.number} recibida, fecha de entrega programada: #{@requested_service.results_date}"}
            @requested_service.received_date = DateTime.now
            @requested_service.save
          end
          
          if @requested_service.status.to_i == RequestedService::IN_PROGRESS
            prv_msg << {:status => RequestedService::RECEIVED, :msg => "Muestra para el servicio #{@requested_service.number} recibida, fecha de entrega programada: #{@requested_service.results_date}"}
            prv_msg << {:status => RequestedService::ASSIGNED, :msg => "El servicio #{@requested_service.number} ha sido asignada a #{@requested_service.user.full_name}"}
            @requested_service.received_date = DateTime.now
            @requested_service.save
          end
        end

        if prev_status.to_i == RequestedService::DELIVERED
          @requested_service.received_date = DateTime.now
          @requested_service.save
        end

        if @requested_service.status.to_i == RequestedService::RECEIVED
          @requested_service.received_date = DateTime.now
          @requested_service.save
        end

        if @requested_service.status.to_i == RequestedService::FINISHED
          @requested_service.finished_date = DateTime.now
          @requested_service.save
        end


        if prev_status.to_i == RequestedService::RECEIVED
          if @requested_service.status.to_i == RequestedService::IN_PROGRESS
            prv_msg << {:status => RequestedService::ASSIGNED, :msg => "El servicio #{@requested_service.number} ha sido asignada a #{@requested_service.user.full_name}"}
          end
        end

        prv_msg.each do |item|
          @requested_service.activity_log.create(user_id: current_user.id,
                                               service_request_id: @requested_service.sample.service_request_id,
                                               sample_id: @requested_service.sample_id,
                                               message_type: 'STATUS',
                                               requested_service_status: item[:status],
                                               message: "#{item[:msg]}.")
        end

        # LOG
        msg = "Muestra para el servicio #{@requested_service.number} regresada a estado inicial" if @requested_service.status.to_i == RequestedService::INITIAL && (prev_status.to_i != RequestedService::REQ_SUP_AUTH || prev_status.to_i != RequestedService::REQ_OWNER_AUTH)
        msg = "El servicio #{@requested_service.number} ha sido autorizado por el supervisor #{current_user.full_name}" if @requested_service.status.to_i == RequestedService::INITIAL && prev_status.to_i == RequestedService::REQ_SUP_AUTH
        msg = "El servicio #{@requested_service.number} ha sido autorizado por #{current_user.full_name}" if @requested_service.status.to_i == RequestedService::INITIAL && prev_status.to_i == RequestedService::REQ_OWNER_AUTH
        msg = "La cotización del servicio #{@requested_service.number} ha sido enviada" if @requested_service.status.to_i == RequestedService::WAITING_START
        msg = "La solicitud de autorización de costeo del servicio #{@requested_service.number} ha sido enviada" if @requested_service.status.to_i == RequestedService::QUOTE_AUTH
        msg = "El costeo del servicio #{@requested_service.number} ha sido regresado" if @requested_service.status.to_i == RequestedService::TO_QUOTE
        msg = "Muestra para el servicio #{@requested_service.number} entregada" if @requested_service.status.to_i == RequestedService::DELIVERED
        msg = "Muestra para el servicio #{@requested_service.number} recibida, fecha de entrega programada: #{@requested_service.results_date}" if @requested_service.status.to_i == RequestedService::RECEIVED
        msg = "El servicio #{@requested_service.number} ha sido asignada a #{@requested_service.user.full_name}" if @requested_service.status.to_i == RequestedService::ASSIGNED
        msg = "El servicio #{@requested_service.number} ha sido suspendida" if @requested_service.status.to_i == RequestedService::SUSPENDED
        msg = "El servicio #{@requested_service.number} ha reiniciado" if @requested_service.status.to_i == RequestedService::REINIT
        msg = "El servicio #{@requested_service.number} ha iniciado" if @requested_service.status.to_i == RequestedService::IN_PROGRESS
        msg = "El servicio #{@requested_service.number} ha finalizado" if @requested_service.status.to_i == RequestedService::FINISHED
        msg = "El servicio #{@requested_service.number} ha sido cancelado" if @requested_service.status.to_i == RequestedService::CANCELED
        msg = "El servicio #{@requested_service.number} ha sido eliminado" if @requested_service.status.to_i == RequestedService::DELETED


        @requested_service.activity_log.create(user_id: current_user.id,
                                               service_request_id: @requested_service.sample.service_request_id,
                                               sample_id: @requested_service.sample_id,
                                               message_type: 'STATUS',
                                               requested_service_status: @requested_service.status,
                                               message: "#{msg}.")

        if !params[:activity_log_msg].blank?
          @requested_service.activity_log.create(user_id: current_user.id,
                                                 service_request_id: @requested_service.sample.service_request_id,
                                                 sample_id: @requested_service.sample_id,
                                                 message_type: 'USER',
                                                 requested_service_status: @requested_service.status,
                                                 message: "#{params[:activity_log_msg]}")
        end

        if @requested_service.status.to_i == RequestedService::QUOTE_AUTH && prev_status.to_i != RequestedService::QUOTE_AUTH
          # Sent mail to admin
          Resque.enqueue(QuoteNeedsAuthMailer, @requested_service.id, current_user.id)
        end

        # CREATE SURVEY
        if @requested_service.status.to_i == RequestedService::FINISHED
          # SURVEY
          survey = @requested_service.requested_service_surveys.new
          survey.token = ('a'..'z').to_a.shuffle[0,8].join
          survey.save
        end


        if params[:send_mail] == 'yes'
          prv_msg << {:status => @requested_service.status, :msg => msg}
          if !params[:activity_log_msg].blank?
            prv_msg << {:status => "USER", :msg => "#{params[:activity_log_msg]}"}
          end
          # Sent mail to involved
          Resque.enqueue(StatusChangeMailer, @requested_service.id, current_user.id, prv_msg)
        end


        # FOLDER STATUS
        set_folder_status(@requested_service.sample.service_request)
        sr = @requested_service.sample.service_request

        # If status changed to FINISHED then change service_request status 
        if @requested_service.status.to_i == RequestedService::FINISHED



          # Enviar mensaje a Vinculación a traves del bus. 
          if (sr.request_type_id == ServiceRequest::SERVICIO_VINCULACION_NO_COORDINADO)
            
            @requested_service.requested_service_technicians.each do |p|
              participation = sr.service_request_participations.new
              participation.user_id = p.user_id
              participation.percentage = p.participation
              participation.save
            end  

            participations = Array.new
            sr.service_request_participations.each do |p|
              participations << {
                "email" => p.user.email,
                "porcentaje" => p.percentage,
              }
            end

            # Publish reporte to Vinculacion system.
            services_costs = []
            services_costs << cost_details_requested_service(@requested_service)
      
            details = {
              "system_id" => sr.system_id, 
              "system_request_id" => sr.system_request_id, 
              "codigo" => sr.number, 
              "servicios" => services_costs
            }


            details['participaciones'] = participations
            QueueBus.publish('recibir_reporte', details)
            sr.system_status = ServiceRequest::SYSTEM_REPORT_SENT
            sr.save
          end
        end
      end

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:service_request_id] = @requested_service.sample.service_request_id
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            if @requested_service.status.to_i == RequestedService::DELETED
              json[:deleted] = 'yes'
            else
              json[:deleted] = 'no'
            end
            json[:status_class] = @requested_service.status_class
            json[:icon_class] = @requested_service.icon_class
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end
    else
      flash[:error] = "Error al actualizar el servicio."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end
  end

  def set_folder_status(sr)
    return if sr.system_status.to_s == '' ||  sr.system_status == ServiceRequest::SYSTEM_FREE
    # FOLDER STATUS
    quoted = 0
    finished = 0
    canceled = 0
    progress = 0
    qty = 0
    sr.sample.each do |s|
      s.requested_service.where("status != ?", RequestedService::DELETED).each do |rs|
        if rs.status.to_i == RequestedService::CANCELED 
          canceled += 1
        else
          qty += 1
        end

        if rs.status.to_i == RequestedService::WAITING_START ||
           rs.status.to_i == RequestedService::INITIAL 
          quoted += 1
        end

        if rs.status.to_i == RequestedService::RECEIVED ||
           rs.status.to_i == RequestedService::ASSIGNED ||
           rs.status.to_i == RequestedService::SUSPENDED ||
           rs.status.to_i == RequestedService::REINIT ||
           rs.status.to_i == RequestedService::IN_PROGRESS ||
           rs.status.to_i == RequestedService::REQ_SUP_AUTH ||
           rs.status.to_i == RequestedService::REQ_OWNER_AUTH
          progress += 1
        end


        if rs.status.to_i == RequestedService::FINISHED
            finished += 1
        end

      end
    end

    if qty > 0
      if finished == qty
        sr.system_status = ServiceRequest::SYSTEM_ALL_FINISHED
      elsif finished > 0
        sr.system_status = ServiceRequest::SYSTEM_PARTIAL_FINISHED
      elsif progress > 0
        sr.system_status = ServiceRequest::SYSTEM_IN_PROGRESS
      elsif quoted == qty
        sr.system_status = ServiceRequest::SYSTEM_QUOTED
      elsif quoted == 0 && canceled == 0
        sr.system_status = ServiceRequest::SYSTEM_TO_QUOTE
      elsif canceled == 0
        sr.system_status = ServiceRequest::SYSTEM_PARTIAL_QUOTED
      end
    else
      if canceled == 0
        sr.system_status = ServiceRequest::SYSTEM_TO_QUOTE
      end
    end
    sr.save
  end

  def new_technician
    
    flash = {}
    
    @requested_service = RequestedService.find(params[:id])

    tech =  @requested_service.requested_service_technicians.new 
    user = User.find(params[:user_id])
    tech.user_id = params[:user_id]
    tech.hours = params[:hours]
    tech.participation = params[:participation]
    tech.hourly_wage = user.hourly_wage

    if tech.save
      flash[:notice] = "Participante agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar al participante."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  def update_participation
    
    flash = {}
    tech = RequestedServiceTechnician.find(params[:tech_id])
    
    tech.participation = params[:participation]

    if tech.save
      flash[:notice] = "Participación actualizada"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = tech.id
            render :json => json
          else
            redirect_to tech
          end
        end
      end

    else

      flash[:error] = "Error al actualizar participación"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = tech.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to tech
          end
        end
      end
    end

  end

  def update_hours
    
    flash = {}
    tech = RequestedServiceTechnician.find(params[:tech_id])
    
    tech.hours = params[:hours]

    if tech.save
      flash[:notice] = "Horas actualizadas"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = tech.id
            render :json => json
          else
            redirect_to tech
          end
        end
      end

    else

      flash[:error] = "Error al actualizar horas"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = tech.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to tech
          end
        end
      end
    end

  end

  def technicians_table
    @requested_service = RequestedService.find(params[:id])
    render :layout => false
  end

  def delete_tech

    flash = {}
    tech = RequestedServiceTechnician.find(params[:tech_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if tech.destroy
      flash[:notice] = "Participante eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = tech.id
            render :json => json
          else
            redirect_to tech
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el participante."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = tech.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to tech
          end
        end
      end
    end
    
  end

  def new_equipment
    
    flash = {}
    
    @requested_service = RequestedService.find(params[:id])

    eq =  @requested_service.requested_service_equipments.new 
    the_eq = Equipment.find(params[:eq_id])
    eq.equipment_id = params[:eq_id]
    eq.hours = params[:hours]
    if @requested_service.service_request.is_vinculacion?
      eq.hourly_rate = the_eq.hourly_rate
    else
      eq.hourly_rate = the_eq.internal_hourly_rate
    end

    if eq.save
      flash[:notice] = "Equipo agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar el equipo."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  
  def update_eq_hours
    
    flash = {}
    eq = RequestedServiceEquipment.find(params[:eq_id])
    
    eq.hours = params[:hours]

    if eq.save
      flash[:notice] = "Horas actualizadas"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = eq.id
            render :json => json
          else
            redirect_to eq
          end
        end
      end

    else

      flash[:error] = "Error al actualizar horas"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = eq.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to eq
          end
        end
      end
    end

  end

  def equipment_table
    @requested_service = RequestedService.find(params[:id])
    render :layout => false
  end

  def delete_eq

    flash = {}
    eq = RequestedServiceEquipment.find(params[:eq_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if eq.destroy
      flash[:notice] = "Equipo eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = eq.id
            render :json => json
          else
            redirect_to eq
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el equipo."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = eq.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to eq
          end
        end
      end
    end
    
  end


  def new_material
    
    flash = {}
    
    @requested_service = RequestedService.find(params[:id])

    mat =  @requested_service.requested_service_materials.new 
    the_mat = Material.find(params[:mat_id])
    mat.material_id = the_mat.id
    mat.quantity = params[:quantity]
    mat.unit_price = the_mat.unit_price

    if mat.save
      flash[:notice] = "Material agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar el material."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  
  def update_mat_qty
    
    flash = {}
    mat = RequestedServiceMaterial.find(params[:mat_id])
    
    mat.quantity = params[:quantity]

    if mat.save
      flash[:notice] = "Cantidad actualizada"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = mat.id
            render :json => json
          else
            redirect_to mat
          end
        end
      end

    else

      flash[:error] = "Error al actualizar la cantidad"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = mat.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to mat
          end
        end
      end
    end

  end

  def materials_table
    @requested_service = RequestedService.find(params[:id])
    render :layout => false
  end

  def delete_mat

    flash = {}
    mat = RequestedServiceMaterial.find(params[:mat_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if mat.destroy
      flash[:notice] = "Material eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = mat.id
            render :json => json
          else
            redirect_to mat
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el material."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = mat.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to mat
          end
        end
      end
    end
    
  end


  def new_other
    
    flash = {}
    
    @requested_service = RequestedService.find(params[:id])

    other =  @requested_service.requested_service_others.new 
    other.other_type_id = params[:other_type_id]
    other.concept = params[:concept]
    other.price = params[:price]

    if other.save
      flash[:notice] = "Otro concepto agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar otro."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  
  def update_other_price
    
    flash = {}
    other = RequestedServiceOther.find(params[:other_id])
    
    other.price = params[:price]

    if other.save
      flash[:notice] = "Concepto actualizado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = other.id
            render :json => json
          else
            redirect_to other
          end
        end
      end

    else

      flash[:error] = "Error al actualizar el concepto"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = other.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to other
          end
        end
      end
    end

  end

  def others_table
    @requested_service = RequestedService.find(params[:id])
    render :layout => false
  end

  def delete_other

    flash = {}
    other = RequestedServiceOther.find(params[:other_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if other.destroy
      flash[:notice] = "Concepto eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = other.id
            render :json => json
          else
            redirect_to other
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el concepto."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = other.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to other
          end
        end
      end
    end
    
  end


  def cost_details_requested_service(requested_service)

    # Technicians
    technicians = Array.new
    requested_service.requested_service_technicians.each do |tech|
      technicians << {
        "detalle" => tech.user.full_name,
        "cantidad" => tech.hours,
        "precio_unitario" => tech.hourly_wage 
      }
    end

    # Equipment
    equipment = Array.new
    requested_service.requested_service_equipments.each do |eq|
      equipment << {
        "detalle" => eq.equipment.name,
        "cantidad" => eq.hours,
        "precio_unitario" => eq.hourly_rate
      }
    end

    # Others
    others = Array.new
    requested_service.requested_service_others.each do |ot|
      others << {
        "detalle" => "#{ot.other_type.name}: #{ot.concept}",
        "cantidad" => 1,
        "precio_unitario" => ot.price
      }
    end

    # Details
    details = {
      "bitacora_id"           => requested_service.id,
      "muestra_system_id"     => requested_service.sample.system_id,
      "muestra_identificador" => requested_service.sample.identification,
      "nombre_servicio"       => requested_service.laboratory_service.name,
      "personal"              => technicians,
      "equipos"               => equipment,
      "otros"                 => others
    }

    return details
  end

  def files_list
     @requested_service = RequestedService.find(params[:id])
     @req_services = RequestedService.where(:sample_id => @requested_service.sample_id).order("FIELD(id,#{@requested_service.id}) DESC, id")
     @requested_service_id = params[:id]
     render :layout => false
  end

end
