class RequestedServicesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

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

end
