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

  def get_from_equipment
    @equipment = Equipment.find(params[:id])
    
    @alerts = {}
    @technician = 0
    @equipment_id = params[:id]
    @laboratory_service_id = 0
    @from = "equipment"
    @from_id = params[:id]

    @equipment.alerts.order('created_at DESC').each do |alert|
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
    mensaje_enviar = ''
    if params[:alert][:laboratory_service_id] == "0"
      params[:alert].delete(:laboratory_service_id)
    else
      from = 'laboratory_service'
      servicio = LaboratoryService.find(params[:alert][:laboratory_service_id])
      from_id = params[:alert][:laboratory_service_id]
      mensaje_enviar = "Servicio: #{servicio.name}\nMensaje: #{params[:alert][:message]}"
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
      equipo = Equipment.find(params[:alert][:equipment_id])
      mensaje_enviar = "Equipo: #{equipo.name}\nMensaje: #{params[:alert][:message]}"
      from_id = params[:alert][:equipment_id]
    end

    @alert = Alert.new(params[:alert])

    if @alert.save
      flash[:notice] = "Alerta creada."

      QueueBus.publish('recibir_alerta', {:alerta_id => @alert.id, :email => current_user.email, :mensaje => mensaje_enviar, :lista => alerted_services(@alert)})

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


  private
  def alerted_services(alert)
    list = []

    # if alert.technician_id > 0
    #   # TODO
    # end
    
    if alert.equipment_id.to_i > 0
      eq = Equipment.find(alert.equipment_id)
      list = list + eq.requested_services.where("(status >= #{RequestedService::INITIAL} AND status < #{RequestedService::FINISHED}) OR (number = 'TEMPLATE')").pluck(:laboratory_service_id).uniq
    end

    if alert.laboratory_service_id.to_i > 0
      list << alert.laboratory_service_id
    end
  
    return list

  end

end
