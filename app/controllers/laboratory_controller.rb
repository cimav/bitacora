class LaboratoryController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def live_search
    @requested_services = RequestedService.joins(:sample).joins(:laboratory_service).joins('LEFT OUTER JOIN service_requests ON service_requests.id = samples.service_request_id').joins('LEFT OUTER JOIN users ON users.id = service_requests.user_id').where('laboratory_id = :lab',  {:lab => params[:id]})
    if params[:lrs_status] != '0'
      if params[:lrs_status] == 'abiertos'
        abiertos = []
        abiertos << RequestedService::INITIAL
        abiertos << RequestedService::RECEIVED
        abiertos << RequestedService::ASSIGNED
        abiertos << RequestedService::SUSPENDED
        abiertos << RequestedService::REINIT
        abiertos << RequestedService::IN_PROGRESS
        @requested_services = @requested_services.where("requested_services.status IN (#{abiertos.join(',')})")
      else
        @requested_services = @requested_services.where('requested_services.status' => params[:lrs_status])
      end
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
    @requested_services = @requested_services.order('users.first_name, users.last_name, requested_services.created_at DESC')
    render :layout => false
  end

  def admin
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def admin_members
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end
  
  def admin_services
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def new
    @laboratory_service = LaboratoryService.new
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

  def admin_lab_services_live_search
    @laboratory = Laboratory.find(params[:id])

    @laboratory_services = @laboratory.laboratory_services.order('name')

    if params[:admin_lab_service_type] != '0'
      @laboratory_services = @laboratory_services.where(:service_type_id => params[:admin_lab_service_type])
    end


    if !params[:q].blank?
      @laboratory_services = @laboratory_services.where("(description LIKE :q OR name LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def new_service
    @laboratory = Laboratory.find(params[:id])
    @laboratory_service = @laboratory.laboratory_services.new
    render :layout => false
  end

  def admin_lab_members_live_search
    @laboratory = Laboratory.find(params[:id])

    @laboratory_members = @laboratory.laboratory_members

    if params[:admin_lab_member_access] != '0'
      @laboratory_members = @laboratory_members.includes(:user).where(:access => params[:admin_lab_member_access])
    end


    if !params[:q].blank?
      @laboratory_members = @laboratory_members.includes(:user).where("(users.first_name LIKE :q OR users.last_name LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def new_member
    @laboratory = Laboratory.find(params[:id])
    @laboratory_member = @laboratory.laboratory_members.new
    render :layout => false
  end



end
