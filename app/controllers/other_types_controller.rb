class OtherTypesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @other_type = OtherType.find(params[:id])
    render :layout => false 
  end

  def live_search
    @other_type = OtherType.order('name')
    if !params[:q].blank?
      @other_type = @other_type.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def create
    @other_type = OtherType.new(params[:other_type])
    flash = {}
    
    if (@other_type.save)
      flash[:notice] = "Tipo agregado satisfactoriamente (#{@other_type.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @other_type.id
            json[:name] = @other_type.name
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
            json[:errors] = @other_type.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @other_type
          end
        end
      end
    end
  end

  def new
    @other_type = OtherType.new
    render :layout => false
  end

  def edit
    @other_type = OtherType.find(params[:id])
    render :layout => false
  end

  def update
    @other_type = OtherType.find(params[:id])

    flash = {}
    if @other_type.update_attributes(params[:other_type])
      flash[:notice] = "Tipo actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @other_type.id
            json[:display] = @other_type.name
            render :json => json
          else
            redirect_to @other_type
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
            json[:errors] = @other_type.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @other_type
          end
        end
      end
    end
  end
end
