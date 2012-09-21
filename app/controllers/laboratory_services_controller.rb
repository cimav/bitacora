class LaboratoryServicesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  def live_search
    @laboratory_services = LaboratoryService.order('name')

    if params[:service_type] != '0'
      @laboratory_services = @laboratory_services.where(:service_type_id => params[:service_type])
    end  

    if params[:laboratory] != '0'
      @laboratory_services = @laboratory_services.where(:laboratory_id => params[:laboratory])
    end  

    if !params[:q].blank?
      @laboratory_services = @laboratory_services.where("(description LIKE :q OR name LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def for_sample
    @laboratory_service = LaboratoryService.find(params[:id])
    @sample = Sample.find(params[:sample_id])
    render :layout => false
  end

  def create
    @laboratory_service = LaboratoryService.new(params[:laboratory_service])
    flash = {}
    if (@laboratory_service.save)
      flash[:notice] = "Nuevo servicio creado satisfactoriamente (#{@laboratory_service.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @laboratory_service.id
            json[:name] = @laboratory_service.name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo crear el servicio"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_service
          end
        end
      end
    end
  end

  def edit
    @laboratory_service = LaboratoryService.find(params[:id])
    render :layout => false
  end

  def update
    @laboratory_service = LaboratoryService.find(params[:id])

    flash = {}
    if @laboratory_service.update_attributes(params[:laboratory_service])
      flash[:notice] = "Servicio actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @laboratory_service
          end
        end
      end
    else
      flash[:error] = "Error al actualizar servicio"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_service
          end
        end
      end
    end
  end

end
