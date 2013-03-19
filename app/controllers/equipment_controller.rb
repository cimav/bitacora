class EquipmentController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def create
    @equipment = Equipment.new(params[:equipment])
    flash = {}
    @equipment.hourly_rate = 0
    if (@equipment.save)
      flash[:notice] = "Equipo de laboratorio agregado satisfactoriamente (#{@equipment.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @equipment.id
            json[:name] = @equipment.name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar el equipo"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @equipment.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @equipment
          end
        end
      end
    end
  end

  def edit
    @equipment = Equipment.find(params[:id])
    render :layout => false
  end

  def update
    @equipment = Equipment.find(params[:id])

    flash = {}
    if @equipment.update_attributes(params[:equipment])
      flash[:notice] = "Equipo actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @equipment
          end
        end
      end
    else
      flash[:error] = "Error al actualizar equipo"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @equipment.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @equipment
          end
        end
      end
    end
  end
end
