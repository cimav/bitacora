class ProvidersController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @provider = Provider.find(params[:id])
    render :layout => false 
  end

  def live_search
    @provider = Provider.order('name')
    if !params[:q].blank?
      @provider = @provider.where("(name LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def create
    @provider = Provider.new(params[:provider])
    flash = {}
    
    if (@provider.save)
      flash[:notice] = "Proveedor agregado satisfactoriamente (#{@provider.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @provider.id
            json[:name] = @provider.name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar el Proveedor"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @provider.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @provider
          end
        end
      end
    end
  end

  def new
    @provider = Provider.new
    render :layout => false
  end

  def edit
    @provider = Provider.find(params[:id])
    render :layout => false
  end

  def update
    @provider = Provider.find(params[:id])

    flash = {}
    if @provider.update_attributes(params[:provider])
      flash[:notice] = "Proveedor actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @provider.id
            json[:display] = @provider.name
            render :json => json
          else
            redirect_to @provider
          end
        end
      end
    else
      flash[:error] = "Error al actualizar Proveedor"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @provider.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @provider
          end
        end
      end
    end
  end
end
