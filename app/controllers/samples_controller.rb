class SamplesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @sample = Sample.find(params['id'])
    render :layout => false
  end
  
  def requested_services_list
    @sample = Sample.find(params['id'])
    @request = @sample.service_request
    render :layout => false
  end

  def lab_view_requested_services_list
    @sample = Sample.find(params['id'])
    @request = @sample.service_request
    render :layout => false
  end

  def new_dialog
    @request = ServiceRequest.find(params[:service_request_id])
    render :layout => false
  end

  def edit_dialog
    @sample = Sample.find(params[:id])
    render :layout => false
  end

  def create
    @sample = Sample.new(params[:sample])

    flash = {}
    if @sample.save
      flash[:notice] = "Muestra agregada."

      # LOG
      @sample.activity_log.create(user_id: current_user.id, 
                                           service_request_id: @sample.service_request_id, 
                                           requested_service_id: 0, 
                                           message_type: 'CREATE', 
                                           message: "Muestra #{@sample.number} agregada")

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:service_request_id] = @sample.service_request_id
            json[:id] = @sample.id
            render :json => json
          else 
            redirect_to @sample
          end
        end
      end
    else
      flash[:error] = "Error al crear muestra."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @sample.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @sample
          end
        end
      end
    end
  end

  def update 
    @sample = Sample.find(params[:id])

    changes = '<ul>'

    
    if @sample.identification != params[:sample][:identification]
      changes = changes + "<li>Identificación de muestra: De <em>'#{@sample.identification}'</em> cambio a <em>'#{params[:sample][:identification]}'</em></li>"
    end

    if @sample.description != params[:sample][:description]
      changes = changes + "<li>Descripción de muestra: De <em>'#{@sample.description}'</em> cambio a <em>'#{params[:sample][:description]}'</em></li>"
    end

    params[:sample][:sample_details_attributes].each do |i,sd|
      sd_item = @sample.sample_details.find(sd[:id])
      if sd_item.client_identification != sd[:client_identification]
        sd_id = "#{@sample.service_request.number.to_s[0..6]}-#{sd_item.consecutive.to_s.rjust(3, '0')}"
        changes = changes + "<li>Identificación #{sd_id}: De <em>'#{sd_item.client_identification}'</em> cambio a <em>'#{sd[:client_identification]}'</em></li>"
      end
    end

    changes = changes + '</ul>'

    flash = {}
    if @sample.update_attributes(params[:sample])
      flash[:notice] = "Muestra actualizada."
      respond_with do |format|
        format.html do
          if request.xhr?
            @sample.activity_log.create(user_id: current_user.id, 
                                         service_request_id: @sample.service_request_id, 
                                         requested_service_id: 0, 
                                         message_type: 'SAMPLE_UPDATE', 
                                         message: "Muestra #{@sample.number} actualizada: #{changes}".html_safe)

            json = {}
            json[:flash] = flash
            json[:service_request_id] = @sample.service_request_id
            render :json => json
          else 
            redirect_to @sample
          end
        end
      end
    else
      flash[:error] = "Error al actualizar la muestra."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @sample.errors
            json[:service_request_id] = @sample.service_request_id
            render :json => json, :status => :unprocessable_entity
          else 
            redirect_to @sample
          end
        end
      end
    end
  end

end
