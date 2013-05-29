class ServiceTypesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @service_type = ServiceType.find(params[:id])
    render :layout => false 
  end

  def live_search
    @service_type = ServiceType.order('name')
    if !params[:q].blank?
      @service_type = @service_type.where("(name LIKE :q OR short_name LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def create
    @service_type = ServiceType.new(params[:service_type])
    flash = {}
    
    if (@service_type.save)
      flash[:notice] = "Tipo agregado satisfactoriamente (#{@service_type.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @service_type.id
            json[:name] = @service_type.name
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
            json[:errors] = @service_type.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @service_type
          end
        end
      end
    end
  end

  def new
    @service_type = ServiceType.new
    render :layout => false
  end

  def edit
    @service_type = ServiceType.find(params[:id])
    render :layout => false
  end

  def update
    @service_type = ServiceType.find(params[:id])

    flash = {}
    if @service_type.update_attributes(params[:service_type])
      flash[:notice] = "Tipo actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @service_type.id
            json[:display] = @service_type.name
            render :json => json
          else
            redirect_to @service_type
          end
        end
      end
    else
      flash[:error] = "Error al actualizar tipo"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @service_type.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @service_type
          end
        end
      end
    end
  end
end
