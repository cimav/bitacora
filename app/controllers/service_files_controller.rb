# coding: utf-8
class ServiceFilesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def ui
    @service_request_id = params[:service_request_id]
    @sample_id = params[:sample_id] 
    @requested_service_id = params[:requested_service_id]
    
    # DISABLED: Hack to load files directly uploaded via shared folder
    # req_service = RequestedService.find(@requested_service_id)
    # files = ServiceFile.where(:service_request_id => params[:service_request_id], :sample_id => params[:sample_id], :requested_service_id => params[:requested_service_id])
    # files_array = files.pluck(:file)
    # path = "#{Rails.root}/private/laboratories/#{req_service.laboratory_service.laboratory_id}/servicios/#{req_service.number}"
    # recreate_zip = false
    # # Remove files...
    # files.each do |f|
    #   if !File.file?(f.file.to_s)
    #     f.delete
    #     recreate_zip = true
    #   end 
    # end
    # # Add files...
    # Dir.entries(path).each do |f|
    #   unless files_array.include?(sanitize(f)) 
    #     if File.file?("#{path}/#{f}")
    #       if sanitize(f) != f
    #         FileUtils.mv("#{path}/#{f}", "#{path}/#{sanitize(f)}")
    #         f = sanitize(f)
    #       end
    #       service_file = ServiceFile.new
    #       service_file.user_id = req_service.laboratory_service.laboratory.user_id
    #       service_file.service_request_id = @service_request_id
    #       service_file.sample_id = @sample_id
    #       service_file.requested_service_id = @requested_service_id
    #       #service_file.file = File.open("#{path}/#{f}")
    #       service_file.raw_write_attribute(:file, f) 
    #       service_file.description = f
    #       service_file.file_type = ServiceFile::FILE
    #       service_file.save!
    #       recreate_zip = true
    #     end
    #   end
    # end
    # # Regenerate zip
    # if recreate_zip 
    #   Resque.enqueue(GenerateSampleZip, @sample_id)
    # end

    render :layout => 'standalone'
  end

  def create
    flash = {}
    file_list = []
    is_client_file = false
    params[:service_file]['file'].each do |f|
      @service_file = ServiceFile.new
      @service_file.user_id = current_user.id
      @service_file.service_request_id = params[:service_file]['service_request_id']
      @service_file.sample_id = params[:service_file]['sample_id']
      @service_file.requested_service_id = params[:service_file]['requested_service_id']
      @service_file.file = f
      @service_file.description = f.original_filename
      if (current_user.is_customer_service?)
        @service_file.file_type = ServiceFile::CLIENT
        is_client_file = true
      else
        @service_file.file_type = ServiceFile::FILE
      end

      if @service_file.save
        flash[:notice] = "Archivo subido exitosamente."
      else
        flash[:error] = "Error al subir archivo."
      end
      file_list << {:name => f.original_filename, :url => @service_file.file.to_s }
    end

    file_list_li = ''
    puts file_list

    file_list.each do |i|
      puts i
      file_list_li = file_list_li + '<li><a href="' + i[:url] + '">' + i[:name] + '</a></li>'
    end

    if is_client_file
      @service_file.service_request.activity_log.create(user_id: current_user.id, 
                                             message_type: 'CLIENT_FILE', 
                                             sample_id: 0,
                                             requested_service_id: 0,
                                             message: "Se subieron los documentos del cliente: <ul>#{file_list_li}</ul>".html_safe)
    end
    # Generate zip version
    Resque.enqueue(GenerateSampleZip, params[:service_file]['sample_id'])
    session[:has_upload] = true
    redirect_to :back
  end

  def remove_file
    destroy
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
            json[:newtypeicon] = @service_file.file_type_icon
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
            json[:newtypeicon] = @service_file.file_type_icon
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

  def download_zip 
    sample = Sample.find(params[:sample_id])
    sample_number = sample.number.gsub("/","_")
    path = "#{Rails.root}/public/zip/#{sample.code}/#{sample_number}.zip"
    if File.exist?(path)
      # send_file path, :type => 'application/zip', :disposition => 'attachment', :x_sendfile => true, :filename => "#{sample.number}.zip"
      redirect_to "/zip/#{sample.code}/#{sample_number}.zip"
    else
      # Generate zip version
      Resque.enqueue(GenerateSampleZip, params[:sample_id])
    end
  end

  def zip_ready 
    sample = Sample.find(params[:sample_id])
    sample_number = sample.number.gsub("/","_")
    path = "#{Rails.root}/public/zip/#{sample.code}/#{sample_number}.zip"
    json = {}
    if File.exist?(path)
      json[:ready] = true
      json[:url] = "/service_files/zip/#{sample.id}"
    else
      json[:url] = "/service_files/generate_zip/#{sample.id}"
      json[:ready] = false
    end
    render :json => json
  end

  def generate_zip
    # sample = Sample.find(params[:sample_id])
    # path = "#{Rails.root}/private/zip/#{sample.number}.zip"
    Resque.enqueue(GenerateSampleZip, params[:sample_id])
    json = {}
    json[:generate] = true
    render :json => json
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
