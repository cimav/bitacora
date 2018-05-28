class SubstancesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def index
    @laboratory = Laboratory.find(params[:id])
    render :layout => false 
  end

  def show
    @substance = Substance.find(params[:id])
    render :layout => false 
  end

  def live_search
    @substance = Substance.where('status <> :s', {:s => Substance::STATUS_DELETED}).order('name')
    if !params[:search_laboratory_id].blank? && params[:search_laboratory_id] != '0'
      @substance = @substance.where("laboratory_id = :c", {:c => params[:search_laboratory_id]}) 
    end
    if !params[:q].blank?
      @substance = @substance.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def create
    @substance = Substance.new(params[:substance])
    flash = {}
    
    @substance.hourly_rate = 0 if !params[:substance][:hourly_rate].blank?

    if (@substance.save)
      flash[:notice] = "Sustancia agregada satisfactoriamente (#{@substance.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @substance.id
            json[:name] = @substance.name
            json[:lab_id] = @substance.laboratory_id
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar la sustancia"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @substance.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @substance
          end
        end
      end
    end
  end

  def new
    @substance = Substance.new
    @laboratory_id = params[:laboratory_id]
    render :layout => false
  end

  def edit
    @substance = Substance.find(params[:id])
    render :layout => false
  end

  def update
    @substance = Substance.find(params[:id])

    flash = {}
    if @substance.update_attributes(params[:substance])
      flash[:notice] = "Sustancia actualizada."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @substance.id
            json[:name] = @substance.name
            json[:lab_id] = @substance.laboratory_id
            json[:laboratory] = @substance.laboratory.name
            render :json => json
          else
            redirect_to @substance
          end
        end
      end
    else
      flash[:error] = "Error al actualizar sustancia"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @substance.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @substance
          end
        end
      end
    end
  end
  
end
