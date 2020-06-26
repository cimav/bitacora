class MaintenancesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    @equipment = Equipment.find(params[:equipment_id])
    render :layout => false 
  end

  def show
    @maintenance = Maintenance.find(params[:id])
    render :layout => false 
  end

  def create
  	params[:maintenance][:equipment_id] = params[:equipment_id]
    @maintenance = Maintenance.new(params[:maintenance])
    flash = {}
    
    if (@maintenance.save)
      flash[:notice] = "Tipo agregado satisfactoriamente (#{@maintenance.id})"

      # LOG
      @maintenance.activity_log.create(user_id: current_user.id, 
                                           message_type: 'CREATE', 
                                           sample_id: -1,
                                           requested_service_id: -1,
                                           service_request_id: -1,
                                           message: "Mantenimiento programado")

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @maintenance.id
            json[:equipment_id] = @maintenance.equipment_id
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar el tipo"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @maintenance.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @maintenance
          end
        end
      end
    end
  end

  def new
  	@equipment = Equipment.find(params[:equipment_id])
    @maintenance = Maintenance.new
    render :layout => false
  end

  def edit
    @maintenance = Maintenance.find(params[:id])
    @equipment = @maintenance.equipment

    render :layout => false
  end

  def update
    @maintenance = Maintenance.find(params[:id])

    flash = {}
    if @maintenance.update_attributes(params[:maintenance])
      flash[:notice] = "Mantenimiento actualizado."
      # LOG
      @maintenance.activity_log.create(user_id: current_user.id, 
                                           message_type: 'UPDATE', 
                                           sample_id: -1,
                                           requested_service_id: -1,
                                           service_request_id: -1,
                                           message: "Mantenimiento actualizado")
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @maintenance.id
            json[:equipment_id] = @maintenance.equipment_id
            json[:display] = @maintenance.name
            render :json => json
          else
            render :layout => false
          end
        end
      end
    else
      flash[:error] = "Error al actualizar mantenimiento"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @maintenance.errors
            render :json => json, :status => :unprocessable_entity
          else
            render :layout => false
          end
        end
      end
    end
  end
end
