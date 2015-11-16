class AlertsController < ApplicationController
    before_filter :auth_required
  respond_to :html, :json

  def get_from_laboratory_service
    @laboratory_service = LaboratoryService.find(params[:id])
    
    @alerts = {}
    @technician = 0
    @equipment_id = 0
    @laboratory_service_id = params[:id]
    @from = "laboratory_service"
    @from_id = params[:id]

    @laboratory_service.alerts.order('created_at DESC').each do |alert|
      @alerts[alert.created_at] = alert
    end
    render 'show', :layout => false
  end

  def resolve 
    @alert = Alert.find(params[:id])
    @alert.end_date = DateTime.now
    @alert.status = Alert::SOLVED
    
    if @alert.save
      flash[:notice] = "Alerta resuelta."

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @alert.id
            json[:from] = params[:from]
            json[:from_id] = params[:from_id]
            render :json => json
          else
            redirect_to @alert
          end
        end
      end
    end

  end

  def create
    params[:alert][:user_id] = current_user.id
    params[:alert][:status] = Alert::OPEN
    flash = {}
    if params[:alert][:laboratory_service_id] == "0"
      params[:alert].delete(:laboratory_service_id)
    else
      from = 'laboratory_service'
      from_id = params[:alert][:laboratory_service_id]
    end
    if params[:alert][:technician] == "0"
      params[:alert].delete(:technician)
    else
      from = 'technician'
      from_id = params[:alert][:technician]
    end
    if params[:alert][:equipment_id] == "0"
      params[:alert].delete(:equipment_id)
    else
      from = 'equipment'
      from_id = params[:alert][:equipment_id]
    end

    @alert = Alert.new(params[:alert])

    if @alert.save
      flash[:notice] = "Alerta creada."

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @alert.id
            json[:from] = from
            json[:from_id] = from_id
            render :json => json
          else
            redirect_to @alert
          end
        end
      end
    else
      flash[:error] = "Error al crear alerta."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @alert.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @alert
          end
        end
      end
    end
  end
end
