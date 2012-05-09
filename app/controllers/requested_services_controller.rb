# coding: utf-8
class RequestedServicesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def initial_dialog
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


  def show
    @requested_service = RequestedService.find(params['id'])
    @activity_log = ActivityLog.where("user_id = :u
                                      AND (
                                        (service_request_id = :service_request AND sample_id = 0 AND requested_service_id = 0)
                                        OR (service_request_id = :service_request AND sample_id = :sample AND requested_service_id = 0)
                                        OR (service_request_id = :service_request AND sample_id = :sample AND requested_service_id = :requested_service)
                                      )
                                    ", {:u => current_user,
                                        :service_request => @requested_service.sample.service_request.id,
                                        :sample => @requested_service.sample_id,
                                        :requested_service => @requested_service.id
                                       }).order('created_at DESC')
    render :layout => false
  end

  def create
    @requested_service = RequestedService.new(params[:requested_service])
    if @requested_service.save
      flash[:notice] = "Servicio agregado."

      # LOG
      @requested_service.activity_log.create(user_id: current_user,
                                             service_request_id: @requested_service.sample.service_request_id,
                                             sample_id: @requested_service.sample_id,
                                             message_type: 'CREATE',
                                             requested_service_status: RequestedService::INITIAL,
                                             message: "#{@requested_service.laboratory_service.name} agregado a la muestra #{@requested_service.sample.number}")

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

  def update
    @requested_service = RequestedService.find(params[:id])

    prev_status = @requested_service.status

    if @requested_service.update_attributes(params[:requested_service])
      flash[:notice] = "Servicio actualizado"
      msg = @requested_service.status
      if prev_status != @requested_service.status.to_i
        # LOG
        msg = "Muestra para el análisis #{@requested_service.number} regresada a estado inicial" if @requested_service.status.to_i == RequestedService::INITIAL
        msg = "Muestra para el análisis #{@requested_service.number} recibida" if @requested_service.status.to_i == RequestedService::RECEIVED
        msg = "El análisis #{@requested_service.number} ha sido asignada a ????" if @requested_service.status.to_i == RequestedService::ASSIGNED
        msg = "El análisis #{@requested_service.number} ha sido suspendida" if @requested_service.status.to_i == RequestedService::SUSPENDED
        msg = "El análisis #{@requested_service.number} ha reiniciado" if @requested_service.status.to_i == RequestedService::REINIT
        msg = "El análisis #{@requested_service.number} ha iniciado" if @requested_service.status.to_i == RequestedService::IN_PROGRESS
        msg = "El análisis #{@requested_service.number} ha finalizado" if @requested_service.status.to_i == RequestedService::FINISHED
        msg = "El análisis #{@requested_service.number} ha sido cancelado" if @requested_service.status.to_i == RequestedService::CANCELED
        
        @requested_service.activity_log.create(user_id: current_user,
                                               service_request_id: @requested_service.sample.service_request_id,
                                               sample_id: @requested_service.sample_id,
                                               message_type: 'STATUS',
                                               requested_service_status: @requested_service.status,
                                               message: "#{msg}. #{params[:activity_log_msg]}")
 
      end
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


end
