class ActivityLogController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @from_log = ActivityLog.find(params[:id])
    @log = ActivityLog.where("(
                                 (service_request_id = :service_request AND sample_id = 0 AND requested_service_id = 0)
                                  OR (service_request_id = :service_request AND sample_id = :sample AND requested_service_id = 0)
                                  OR (service_request_id = :service_request AND sample_id = :sample AND requested_service_id = :requested_service)
                                  OR (maintenance_id = :maintenance)
                              )
                              ", {:service_request => @from_log.service_request_id,
                                  :sample => @from_log.sample_id,
                                  :requested_service => @from_log.requested_service_id,
                                  :maintenance => @from_log.maintenance_id
                                 }).order('created_at DESC')
    render :layout => false

  end

  def create
    params[:activity_log][:user_id] = current_user.id
    @log = ActivityLog.new(params[:activity_log])
    flash = {}

    if @log.save
      flash[:notice] = "Comentario agregado a la bitacora."

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @log.id
            render :json => json
          else
            redirect_to @log
          end
        end
      end
    else
      flash[:error] = "Error al crear la entrada en la bitacora."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @log.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @log
          end
        end
      end
    end
  end

end
