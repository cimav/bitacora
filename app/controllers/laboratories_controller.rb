class LaboratoriesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def new
    @laboratory = Laboratory.new
    render :layout => false
  end

  def edit
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def live_search
    @laboratories = Laboratory.where('status = :s', {:s => Laboratory::ACTIVE}).order('name')
    if !params[:search_business_unit_id].blank? && params[:search_business_unit_id] != '0'
      @laboratories = @laboratories.where("business_unit_id = :c", {:c => params[:search_business_unit_id]}) 
    end
    if !params[:q].blank?
      @laboratories = @laboratories.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end
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

  def create
    @laboratory = Laboratory.new

    flash = {}

    if @laboratory.update_attributes(params[:laboratory])
      flash[:notice] = "Laboratorio creado"
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
      flash[:error] = "Error al crear el laboratorio."
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
