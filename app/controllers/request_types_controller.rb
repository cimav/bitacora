class RequestTypesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @request_type = RequestType.find(params[:id])
    render :layout => false 
  end

  def live_search
    @request_type = RequestType.order('name')
    if !params[:q].blank?
      @request_type = @request_type.where("(name LIKE :q OR short_name LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def create
    @request_type = RequestType.new(params[:request_type])
    flash = {}
    
    if (@request_type.save)
      flash[:notice] = "Tipo agregado satisfactoriamente (#{@request_type.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @request_type.id
            json[:name] = @request_type.name
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
            json[:errors] = @request_type.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @request_type
          end
        end
      end
    end
  end

  def new
    @request_type = RequestType.new
    render :layout => false
  end

  def edit
    @request_type = RequestType.find(params[:id])
    render :layout => false
  end

  def update
    @request_type = RequestType.find(params[:id])

    flash = {}
    if @request_type.update_attributes(params[:request_type])
      flash[:notice] = "Tipo actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @request_type.id
            json[:display] = @request_type.name
            render :json => json
          else
            redirect_to @request_type
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
            json[:errors] = @request_type.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @request_type
          end
        end
      end
    end
  end
end
