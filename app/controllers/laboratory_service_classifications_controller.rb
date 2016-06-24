class LaboratoryServiceClassificationsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def create
    @laboratory_service_classification = LaboratoryServiceClassification.new(params[:laboratory_service_classification])
    flash = {}
    if (@laboratory_service_classification.save)
      flash[:notice] = "Clasificación de servicio de laboratorio agregado satisfactoriamente (#{@laboratory_service_classification.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @laboratory_service_classification.id
            json[:name] = @laboratory_service_classification.name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar la clasificación"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_service_classification.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_service_classification
          end
        end
      end
    end
  end

  def edit
    @laboratory_service_classification = LaboratoryServiceClassification.find(params[:id])
    render :layout => false
  end

  def update
    @laboratory_service_classification = LaboratoryServiceClassification.find(params[:id])

    flash = {}
    if @laboratory_service_classification.update_attributes(params[:laboratory_service_classification])
      flash[:notice] = "Clasificación actualizada."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @laboratory_service_classification
          end
        end
      end
    else
      flash[:error] = "Error al actualizar clasificación"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_service_classification.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_service_classification
          end
        end
      end
    end
  end

end
