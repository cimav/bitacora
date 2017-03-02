class LaboratoryImagesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  def create
    flash = {}
    file_list = []
    is_client_file = false

    params[:laboratory_image]['file'].each do |f|
      @laboratory_image = LaboratoryImage.new
      @laboratory_image.user_id = current_user.id
      @laboratory_image.laboratory_id = params[:laboratory_image]['laboratory_id']
      @laboratory_image.file = f
      @laboratory_image.description = f.original_filename
      puts  @laboratory_image.description
      if @laboratory_image.save
      	puts "YES"
        flash[:notice] = "Imágen subida exitosamente."
      else
      	puts "FUCK"
        flash[:error] = "Error al subir imágen."
      end
    end
    session[:has_upload_image] = true
    render :inline => 'TERMINO'
  end

  def remove_file
    destroy
  end

  def destroy
    @laboratory_image = LaboratoryImage.find(params[:id])
    flash = {}
    if @laboratory_image.destroy
      flash[:notice] = "Archivo eliminado"
      # LOG
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @laboratory_image
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
            redirect_to @laboratory_image
          end
        end
      end
    end

  end

  def update
    @laboratory_image = LaboratoryImage.find(params[:id])
    flash = {}

    if @laboratory_image.update_attributes(params[:laboratory_image])
      flash[:notice] = "Descripción actualizada."
      # LOG
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = params[:id]
            json[:newdesc] = params[:laboratory_image][:description]
            render :json => json
          else
            redirect_to @laboratory_image
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
            json[:newdesc] = params[:laboratory_image][:description]
            json[:errors] = @laboratory_image.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_image
          end
        end
      end
    end
  end

  private
    def sanitize(name)
      name = name.gsub("\\", "/") # work-around for IE
      name = File.basename(name)
      name = name.gsub(CarrierWave::SanitizedFile.sanitize_regexp,"_")
      name = "_#{name}" if name =~ /\A\.+\z/
      name = "unnamed" if name.size == 0
      return name.mb_chars.to_s
    end

end


