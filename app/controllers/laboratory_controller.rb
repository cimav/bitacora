class LaboratoryController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def live_search
    @requested_services = RequestedService.joins(:sample).joins(:laboratory_service).where('laboratory_id = :lab',  {:lab => params[:id]})
    if params[:lrs_status] != '0'
      @requested_services = @requested_services.where('requested_services.status' => params[:lrs_status])
    end
    if params[:lrs_requestor] != '0'
      @requested_services = @requested_services.where('samples.service_request_id IN (SELECT id FROM service_requests WHERE user_id = :req)', {:req => params[:lrs_requestor]})
    end
    if params[:lrs_assigned_to] != '0'
      @requested_services = @requested_services.where('requested_services.user_id' => params[:lrs_assigned_to])
    end
    if !params[:q].blank?
      @requested_services = @requested_services.where("(laboratory_services.description LIKE :q OR laboratory_services.name LIKE :q OR samples.identification LIKE :q OR samples.identification LIKE :q OR samples.description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    @requested_services = @requested_services.order('requested_services.created_at DESC')
    render :layout => false
  end

  def admin
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def admin_users
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end
  
  def admin_services
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def update
    @laboratory = Laboratory.find(params[:id])

    flash = {}

    if @laboratory.update_attributes(params[:laboratory])
      flash[:notice] = "Laboratorio actualizado"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @laboratory.id
            json[:name] = @laboratory.name
            render :json => json
          else
            redirect_to @laboratory
          end
        end
      end
    else
      flash[:error] = "Error al actualizar el laboratorio."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory
          end
        end
      end
    end
  end


end
