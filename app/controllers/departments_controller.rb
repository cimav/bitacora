class DepartmentsController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def new
    @department = Department.new
    render :layout => false
  end

  def edit
    @department = Department.find(params[:id])
    render :layout => false
  end

  def live_search
    @departments = Department.where('status = :s', {:s => Department::ACTIVE}).order('name')
    if !params[:search_business_unit_id].blank? && params[:search_business_unit_id] != '0'
      @departments = @departments.where("business_unit_id = :c", {:c => params[:search_business_unit_id]}) 
    end
    if !params[:q].blank?
      @departments = @departments.where("name LIKE :q", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def update
    @department = Department.find(params[:id])

    flash = {}

    if @department.update_attributes(params[:department])
      flash[:notice] = "Departamento actualizado"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @department.id
            json[:name] = @department.name
            render :json => json
          else
            redirect_to @department
          end
        end
      end
    else
      flash[:error] = "Error al actualizar el Departamento."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @department.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @department
          end
        end
      end
    end
  end

  def create
    @department = Department.new

    flash = {}

    if @department.update_attributes(params[:department])
      flash[:notice] = "Departamento creado"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @department.id
            json[:name] = @department.name
            render :json => json
          else
            redirect_to @department
          end
        end
      end
    else
      flash[:error] = "Error al crear el Departamento."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @department.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @department
          end
        end
      end
    end
  end
end
