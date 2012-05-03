class RequestedServicesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @requested_service = RequestedService.find(params['id'])
    render :layout => false
  end

  def create
    @requested_service = RequestedService.new(params[:requested_service])
    if @requested_service.save
      flash[:notice] = "Servicio agregado."

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
