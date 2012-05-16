class SamplesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @sample = Sample.find(params['id'])
    render :layout => false
  end
  
  def requested_services_list
    @sample = Sample.find(params['id'])
    render :layout => false
  end

  def new_dialog
    @request = ServiceRequest.find(params[:service_request_id])
    render :layout => false
  end

  def create
    @sample = Sample.new(params[:sample])

    if @sample.save
      flash[:notice] = "Muestra agregada."

      # LOG
      @sample.activity_log.create(user_id: current_user.id, 
                                           service_request_id: @sample.service_request_id, 
                                           requested_service_id: 0, 
                                           message_type: 'CREATE', 
                                           message: "Muestra #{@sample.number} agregada")

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:service_request_id] = @sample.service_request_id
            json[:id] = @sample.id
            render :json => json
          else 
            redirect_to @sample
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
            json[:errors] = @sample.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @sample
          end
        end
      end
    end
  end

  def update 
    @sample = Sample.find(params[:id])

    if @sample.update_attributes(params[:sample])
      flash[:notice] = "Muestra actualizada."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else 
            redirect_to @sample
          end
        end
      end
    else
      flash[:error] = "Error al actualizar la muestra."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @sample.errors
            render :json => json, :status => :unprocessable_entity
          else 
            redirect_to @sample
          end
        end
      end
    end
  end

end
