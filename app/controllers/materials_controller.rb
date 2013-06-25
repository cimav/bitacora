class MaterialsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @material = Material.find(params[:id])
    render :layout => false 
  end

  def live_search
    @material = Material.where('status = :s', {:s => Material::ACTIVE}).order('name')
    if !params[:search_unit_id].blank? && params[:search_unit_id] != 'ALL'
      @material = @material.where("unit_id = :c", {:c => params[:search_unit_id]}) 
    end

    if !params[:q].blank?
      @material = @material.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def create
    @material = Material.new(params[:material])
    flash = {}
    
    if (@material.save)
      flash[:notice] = "Consumible de laboratorio agregado satisfactoriamente (#{@material.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @material.id
            json[:name] = @material.name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar el consumible"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @material.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @material
          end
        end
      end
    end
  end

  def new
    @material = Material.new
    render :layout => false
  end

  def edit
    @material = Material.find(params[:id])
    render :layout => false
  end

  def update
    @material = Material.find(params[:id])

    flash = {}
    if @material.update_attributes(params[:material])
      flash[:notice] = "Consumible actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @material.id
            json[:display] = "#{@material.name} (#{@material.unit.name})"
            render :json => json
          else
            redirect_to @material
          end
        end
      end
    else
      flash[:error] = "Error al actualizar consumible"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @material.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @material
          end
        end
      end
    end
  end
end
