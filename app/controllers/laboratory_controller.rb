class LaboratoryController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @laboratory = Laboratory.find(params[:id])
    @filter = {}
    if params[:filter]
      params[:filter].each_line('|') do |s|
        @filter[s[0]] = s.gsub('|','')[1..-1]
      end
    end
    render :layout => false
  end
  
  def live_search
    # @requested_services = RequestedService.where.not(status: RequestedService::DELETED)
    #                                       .joins(:sample)
    #                                       .joins(:laboratory_service)
    #                                       .joins('LEFT OUTER JOIN service_requests ON service_requests.id = samples.service_request_id')
    #                                       .joins('LEFT OUTER JOIN users ON users.id = service_requests.user_id').where('laboratory_id = :lab',  {:lab => params[:id]})
    #                                       .limit(1)

    lab_id = params[:id]
    sql = "SELECT requested_services.id, 
                  requested_services.number, 
                  requested_services.status,
                  requested_services.created_at, 
                  samples.service_request_id, 
                  samples.service_request_id AS sample_service_request,
                  service_requests.status AS service_request_status,
                  laboratory_services.laboratory_id,
                  sample_id,
                  request_types.id AS request_type_id,
                  request_types.short_name AS request_type_short_name,
                  request_types.name AS request_type_name, 
                  service_requests.number AS service_request_number,
                  users.first_name,
                  users.last_name,
                  laboratory_services.name AS laboratory_service_name,
                  vinculacion_client_name,
                  samples.identification AS sample_identification,
                  samples.quantity AS sample_quantity,
                  vinculacion_start_date,
                  vinculacion_end_date,
                  system_status,
                  users.email


           FROM `requested_services` 
                   INNER JOIN `samples` ON `samples`.`id` = `requested_services`.`sample_id` 
                   INNER JOIN `laboratory_services` ON `laboratory_services`.`id` = `requested_services`.`laboratory_service_id` 
                   LEFT OUTER JOIN service_requests ON service_requests.id = samples.service_request_id 
                   LEFT OUTER JOIN users ON users.id = service_requests.user_id 
                   LEFT OUTER JOIN request_types ON request_type_id = request_types.id
           WHERE (`requested_services`.`status` != '-2') 
                  AND (laboratory_id = '#{lab_id}') "

                  
    if params[:lrs_status] != '-todos'
      if params[:lrs_status] == '-abiertos'
        abiertos = []
        abiertos << RequestedService::INITIAL
        abiertos << RequestedService::RECEIVED
        abiertos << RequestedService::ASSIGNED
        abiertos << RequestedService::SUSPENDED
        abiertos << RequestedService::REINIT
        abiertos << RequestedService::IN_PROGRESS
        abiertos << RequestedService::TO_QUOTE
        abiertos << RequestedService::WAITING_START
        sql = sql + " AND (requested_services.status IN (#{abiertos.join(',')}))  "
      else
        sql = sql + " AND requested_services.status = #{params[:lrs_status]}  "
      end
    end
    
    if params[:lrs_requestor] != '0'
      sql = sql + " AND samples.service_request_id IN (SELECT id FROM service_requests WHERE user_id = #{params[:lrs_requestor]}) "
    end
    if params[:lrs_assigned_to] != '0'
      sql = sql + " AND requested_services.user_id = #{params[:lrs_assigned_to]} "
    end

    if params[:lrs_bu] != '0'
      sql = sql + " AND service_requests.user_id IN (SELECT id FROM users WHERE business_unit_id = #{params[:lrs_bu]})"
    end

    if params[:lrs_client] != '0'
      sql = sql + " AND service_requests.vinculacion_client_id = #{params[:lrs_client]} "
    end
    if params[:lrs_type] != '0'
      sql = sql + " AND service_requests.request_type_id = #{params[:lrs_type]}"
    end
    if !params[:q].blank?
      q = "%#{params[:q]}%"
      sql = sql + " AND (laboratory_services.description LIKE #{q} OR laboratory_services.name LIKE #{q} OR samples.identification LIKE #{q} OR requested_services.number LIKE #{q} OR samples.description LIKE #{q})"
    end
    sql = sql + " ORDER BY requested_services.created_at DESC"

    @requested_services = RequestedService.find_by_sql(sql)

    render :layout => false
  end

  def admin
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def reports
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def report_vinculacion
    @laboratory = Laboratory.find(params[:id])

    if (params[:start_date]) 
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      @start_date = DateTime.now.strftime "%Y-01-01"
      @end_date = DateTime.now.strftime "%Y-%m-%d"
    end


    @registros = ReporteFinalizados.where("laboratorio_id = #{@laboratory.id} AND fecha_finalizado_real BETWEEN '#{@start_date}' AND '#{@end_date}'")


    respond_with do |format|
      format.html do
        render :layout => false
      end
      format.xls do
        rows = Array.new

        @registros.collect do |r|
          rows << {'SIGRE' => (r.sigre_id rescue '-'), 
                   'CODIGO' => (r.codigo rescue '-'), 
                   'TIPO' => (r.tipo rescue '-'), 
                   'CLIENTE' => (r.cliente rescue '-'), 
                   'DESCRIPCION' => (r.descripcion rescue '-'), 
                   'LABID' => (r.laboratorio_id rescue '-'), 
                   'LABORATORIO' => (r.laboratorio rescue '-'), 
                   'CLASIFICADOR' => (r.clasificador rescue '-'), 
                   'SERVICIO' => (r.servicio_laboratorio rescue '-'), 
                   'INICIO' => (r.fecha_inicio.strftime("%Y/%m/%d %H:%M") rescue '-'),
                   'FIN' => (r.fecha_fin.strftime("%Y/%m/%d %H:%M") rescue '-'),
                   'FECHA_FINALIZADO' => (r.fecha_finalizado_real.strftime("%Y/%m/%d %H:%M") rescue '-'),
                   'COTIZACION' => (r.cotizacion_consecutivo rescue '-'), 
                   'PRECIO_VENTA' => (r.precio_venta rescue '-'), 
                   'COSTO_INTERNO' => (r.costo_interno rescue '-'), 
                   'TOTAL' => (r.total rescue '-'), 
                   'PORCENTAJE' => (r.porcentaje rescue '-'), 
                   'CORRESPONDE' => (r.corresponde rescue '-'),
                 }
        end
        column_order = ['SIGRE', 'CODIGO','TIPO','CLIENTE','DESCRIPCION','LABID','LABORATORIO','CLASIFICADOR','SERVICIO','INICIO','FIN','FECHA_FINALIZADO','COTIZACION','PRECIO_VENTA','COSTO_INTERNO','TOTAL','PORCENTAJE','CORRESPONDE']
        to_excel(rows,column_order,"VINCULACION","Reporte_Vinculacion")
      end
    end

  end

  def reports_general
    @laboratory = Laboratory.find(params[:id])

    if (params[:start_date]) 
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      @start_date = DateTime.now.strftime "%Y-01-01"
      @end_date = DateTime.now.strftime "%Y-%m-%d"
    end

    @requested_services = RequestedService.where.not(status: RequestedService::DELETED)
                                          .joins('LEFT OUTER JOIN samples ON sample_id = samples.id')
                                          .joins('LEFT OUTER JOIN laboratory_services ON laboratory_service_id = laboratory_services.id')
                                          .joins('LEFT OUTER JOIN laboratory_service_classifications ON laboratory_service_classification_id = laboratory_service_classifications.id')
                                          .joins('LEFT OUTER JOIN service_requests ON service_requests.id = samples.service_request_id')
                                          .joins('LEFT OUTER JOIN users ON users.id = service_requests.user_id')
                                          .where('laboratory_services.laboratory_id = :lab',  {:lab => params[:id]})
    @requested_services = @requested_services.where("requested_services.created_at BETWEEN :start AND :end", {:start => @start_date, :end => @end_date})
    @requested_services = @requested_services.order('requested_services.created_at ASC')

    respond_with do |format|
      format.html do
        render :layout => false
      end
      format.xls do
        rows = Array.new

        @requested_services.collect do |rs|
          rows << {'Fecha' => rs.created_at,
                   'Código' => rs.number,
                   'Servicio' => rs.laboratory_service.name,
                   'Clasificador' => (rs.laboratory_service.laboratory_service_classification.name rescue '-'),
                   'Tipo' => (rs.service_request.request_type.name rescue '-'),
                   'Carpeta' => ("#{rs.service_request.number}: #{rs.service_request.request_link}" rescue '-'),
                   'Solicitante' => (rs.service_request.user.full_name rescue '-'),
                   'Muestra' => (rs.sample.identification rescue '-'),
                   'Cantidad' => (rs.sample.quantity rescue '-'),
                   'Tecnico_Asignado' => (rs.user.full_name rescue '-'),
                   'Estado' => rs.status_text,
                 }
        end
        column_order = ["Fecha","Código","Servicio","Clasificador","Tipo","Carpeta","Solicitante","Muestra","Cantidad","Tecnico_Asignado","Estado"]
        to_excel(rows,column_order,"Servicios","Reporte_General")
      end
    end
  end

  def report_equipment
    @laboratory = Laboratory.find(params[:id])

    if (params[:start_date]) 
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    else
      @start_date = DateTime.now.strftime "%Y-01-01"
      @end_date = DateTime.now.strftime "%Y-%m-%d"
    end

    sql = "SELECT equipment.name, 
                      COUNT(requested_services.id) AS services_sum, 
                      SUM(IF(requested_services.number = 'TEMPLATE',0,samples.quantity)) AS samples_sum, 
                      SUM(IF(requested_services.number = 'TEMPLATE',0,hours)) AS hours_sum  
               FROM equipment 
               LEFT JOIN requested_service_equipments ON equipment.id = equipment_id 
               LEFT JOIN requested_services ON requested_service_id = requested_services.id  
               LEFT JOIN samples ON sample_id = samples.id 
               WHERE 
                 equipment.laboratory_id = ?
                 AND requested_services.created_at BETWEEN ? AND ?
               GROUP BY equipment.id"

    @eq_use = Equipment.find_by_sql([sql, @laboratory.id, @start_date, @end_date])


    respond_with do |format|
      format.html do
        render :layout => false
      end
      format.xls do
        rows = Array.new

        @eq_use.collect do |e|
          rows << {'Nombre' => e.name,
                   'Servicios' => e.services_sum,
                   'Muestras' => e.samples_sum,
                   'Horas' => e.hours_sum
                 }
        end
        column_order = ["Nombre", "Servicios", "Muestras", "Horas"]
        to_excel(rows,column_order,"Servicios","Reporte_Uso_Equipo")
      end
    end
  end

  def admin_members
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end
  
  def admin_services
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def admin_equipment
    @laboratory = Laboratory.find(params[:id])
    render :layout => false
  end

  def admin_classifications
    @laboratory = Laboratory.find(params[:id])
    @laboratory_image = @laboratory.laboratory_image.new
    render :layout => false
  end

  def admin_images
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

  def services_catalog
    respond_with do |format|
     format.xls do
        rows = Array.new
        @laboratory = Laboratory.find(params[:id])
        @laboratory_services = @laboratory.laboratory_services.order('name')
        @laboratory_services.collect do |item|
          rows << {'ID' => item.id,
                   'Nombre' => item.name,
                   'Descripcion' => item.description
                   }
        end
        column_order = ["ID", "Nombre", "Descripcion"]
        to_excel(rows, column_order, "Servicios", "Servicios")
      end
    end

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
      @laboratory_members = @laboratory_members.joins(:user).where(:access => params[:admin_lab_member_access])
    end


    if !params[:q].blank?
      @laboratory_members = @laboratory_members.joins(:user).where("(users.first_name LIKE :q OR users.last_name LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def new_member
    @laboratory = Laboratory.find(params[:id])
    @laboratory_member = @laboratory.laboratory_members.new
    render :layout => false
  end

  def admin_lab_equipment_live_search
    @laboratory = Laboratory.find(params[:id])

    @laboratory_equipment = @laboratory.equipment

    if !params[:q].blank?
      @laboratory_equipment = @laboratory_equipment.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def new_equipment
    @laboratory = Laboratory.find(params[:id])
    @laboratory_equipment = @laboratory.equipment.new
    render :layout => false
  end

  def admin_lab_classification_live_search
    @laboratory = Laboratory.find(params[:id])

    @laboratory_service_classifications = @laboratory.laboratory_service_classifications

    if !params[:q].blank?
      @laboratory_service_classifications = @laboratory_service_classifications.where("(name LIKE :q OR description LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def new_classification
    @laboratory = Laboratory.find(params[:id])
    @laboratory_service_classification = @laboratory.laboratory_service_classifications.new
    render :layout => false
  end



end
