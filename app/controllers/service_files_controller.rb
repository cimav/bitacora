# coding: utf-8
class ServiceFilesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def ui
    @service_request_id = params[:service_request_id]
    @sample_id = params[:sample_id] 
    @requested_service_id = params[:requested_service_id]
    @files = ServiceFile.where(:service_request_id => params[:service_request_id], :sample_id => params[:sample_id], :requested_service_id => params[:requested_service_id]).order('file_type', 'description')
    render :layout => 'standalone'
  end

  def create
    flash = {}
    params[:service_file]['file'].each do |f|
      @service_file = ServiceFile.new
      @service_file.user_id = current_user.id
      @service_file.service_request_id = params[:service_file]['service_request_id']
      @service_file.sample_id = params[:service_file]['sample_id']
      @service_file.requested_service_id = params[:service_file]['requested_service_id']
      @service_file.file = f
      @service_file.description = f.original_filename
      @service_file.file_type = ServiceFile::FILE
      if @service_file.save
        flash[:notice] = "Archivo subido exitosamente."
      else
        flash[:error] = "Error al subir archivo."
      end
    end

    redirect_to :back
  end

  def destroy
    @service_file = ServiceFile.find(params[:id])
    flash = {}
    if @service_file.destroy
      flash[:notice] = "Archivo eliminado"
      # LOG
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @service_file
          end
        end
      end
    else
      flash[:error] = "Error al eliminar archivo"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @service_file
          end
        end
      end
    end

  end

  def update
    @service_file = ServiceFile.find(params[:id])
    flash = {}

    if @service_file.update_attributes(params[:service_file])
      flash[:notice] = "Descripción actualizada."
      # LOG
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = params[:id]
            json[:newdesc] = params[:service_file][:description]
            json[:newtype] = params[:service_file][:file_type]
            render :json => json
          else
            redirect_to @service_file
          end
        end
      end
    else
      flash[:error] = "Error al actualizar la descripción."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = params[:id]
            json[:newdesc] = params[:service_file][:description]
            json[:newtype] = params[:service_file][:file_type]
            json[:errors] = @service_file.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @service_file
          end
        end
      end
    end
  end

  def file
    s = ServiceFile.find(params[:id])
    send_file s.file.to_s, :x_sendfile=>true
  end 

end
