# coding: utf-8
class LaboratoryServicesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def live_search
    @laboratory_services = LaboratoryService.where(:is_exclusive_vinculacion => 0, :status => 0).order('name')

    if params[:service_type] != '0'
      @laboratory_services = @laboratory_services.where(:service_type_id => params[:service_type])
    end  

    if params[:laboratory] != '0'
      @laboratory_services = @laboratory_services.where(:laboratory_id => params[:laboratory])
    end  

    if !params[:q].blank?
      @laboratory_services = @laboratory_services.where("(description LIKE :q OR name LIKE :q)", {:q => "%#{params[:q]}%"})
    end

    render :layout => false
  end

  def add_service_dialog
    render :layout => false
  end

  def for_sample
    @laboratory_service = LaboratoryService.find(params[:id])
    @sample = Sample.find(params[:sample_id])
    render :layout => false
  end

  def create
    @laboratory_service = LaboratoryService.new(params[:laboratory_service])
    flash = {}
    if (@laboratory_service.save)
      flash[:notice] = "Nuevo servicio creado satisfactoriamente (#{@laboratory_service.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @laboratory_service.id
            json[:name] = @laboratory_service.name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo crear el servicio"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_service
          end
        end
      end
    end
  end

  def edit
    @laboratory_service = LaboratoryService.find(params[:id])
    render :layout => false
  end

  def get_grand_total(id)
    requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => id}).first 
    grand_total = RequestedService.find_by_sql(["SELECT IFNULL(SUM(subtotal),0) AS total FROM (
                                                   SELECT SUM(requested_service_equipments.hours * equipment.hourly_rate) AS subtotal 
                                                     FROM requested_service_equipments 
                                                       INNER JOIN equipment ON equipment_id = equipment.id
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id 
                                                   UNION 
                                                     SELECT SUM(requested_service_technicians.hours * users.hourly_wage) AS subtotal 
                                                     FROM requested_service_technicians 
                                                       INNER JOIN users ON user_id = users.id
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id
                                                   UNION
                                                     SELECT SUM(price) AS subtotal 
                                                     FROM requested_service_others 
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id
                                                 ) subtotals", :requested_service => requested_service.id]).first.total
  end

  def get_grand_total_internal(id)
    requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => id}).first 
    grand_total = RequestedService.find_by_sql(["SELECT IFNULL(SUM(subtotal),0) AS total FROM (
                                                   SELECT SUM(requested_service_equipments.hours * equipment.internal_hourly_rate) AS subtotal 
                                                     FROM requested_service_equipments 
                                                       INNER JOIN equipment ON equipment_id = equipment.id
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id 
                                                   UNION 
                                                     SELECT SUM(requested_service_technicians.hours * users.hourly_wage) AS subtotal 
                                                     FROM requested_service_technicians 
                                                       INNER JOIN users ON user_id = users.id
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id
                                                   UNION
                                                     SELECT SUM(price) AS subtotal 
                                                     FROM requested_service_others 
                                                     WHERE requested_service_id = :requested_service
                                                     GROUP BY requested_service_id
                                                 ) subtotals", :requested_service => requested_service.id]).first.total
  end

  def grand_total
    @grand_total = get_grand_total(params[:id])
    @grand_total_internal = get_grand_total_internal(params[:id])
    render :layout => false
  end

  def update_internal_cost(id)
    grand_total = get_grand_total(id)
    grand_total_internal = get_grand_total_internal(id)
    lab_service = LaboratoryService.find(id)
    lab_service.internal_cost = grand_total
    lab_service.evaluation_cost = grand_total_internal
    lab_service.save
  end

  def edit_cost
    @laboratory_service = LaboratoryService.find(params[:id])
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first 
    @grand_total = get_grand_total(params[:id])
    @grand_total_internal = get_grand_total_internal(params[:id])
    render :layout => false
  end

  def update
    @laboratory_service = LaboratoryService.find(params[:id])

    flash = {}
    if @laboratory_service.update_attributes(params[:laboratory_service])
      flash[:notice] = "Servicio actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @laboratory_service
          end
        end
      end
    else
      flash[:error] = "Error al actualizar servicio"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_service
          end
        end
      end
    end
  end



  def new_technician
    
    flash = {}

    
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first

    tech =  @requested_service.requested_service_technicians.new 
    user = User.find(params[:user_id])
    tech.user_id = params[:user_id]
    tech.hours = params[:hours]
    tech.participation = params[:participation]
    tech.hourly_wage = user.hourly_wage

    if tech.save
      update_internal_cost(params[:id])

      flash[:notice] = "Participante agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar al participante."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  def update_participation
    
    flash = {}
    tech = RequestedServiceTechnician.find(params[:tech_id])
    
    tech.participation = params[:participation]

    if tech.save
      flash[:notice] = "Participación actualizada"
     
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = tech.id
            render :json => json
          else
            redirect_to tech
          end
        end
      end

    else

      flash[:error] = "Error al actualizar participación"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = tech.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to tech
          end
        end
      end
    end

  end

  def update_hours
    
    flash = {}
    tech = RequestedServiceTechnician.find(params[:tech_id])
    
    tech.hours = params[:hours]

    if tech.save
      flash[:notice] = "Horas actualizadas"
      update_internal_cost(tech.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = tech.id
            render :json => json
          else
            redirect_to tech
          end
        end
      end

    else

      flash[:error] = "Error al actualizar horas"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = tech.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to tech
          end
        end
      end
    end

  end

  def technicians_table
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first
    render :layout => false
  end

  def delete_tech

    flash = {}
    tech = RequestedServiceTechnician.find(params[:tech_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if tech.destroy
      flash[:notice] = "Participante eliminado"
      update_internal_cost(tech.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = tech.id
            render :json => json
          else
            redirect_to tech
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el participante."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = tech.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to tech
          end
        end
      end
    end
    
  end

  def new_equipment
    
    flash = {}
    
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first

    eq =  @requested_service.requested_service_equipments.new 
    the_eq = Equipment.find(params[:eq_id])
    eq.equipment_id = params[:eq_id]
    eq.hours = params[:hours]
    eq.hourly_rate = the_eq.hourly_rate

    if eq.save
      flash[:notice] = "Equipo agregado"
      update_internal_cost(params[:id])

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar el equipo."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  
  def update_eq_hours
    
    flash = {}
    eq = RequestedServiceEquipment.find(params[:eq_id])
    
    eq.hours = params[:hours]

    if eq.save
      flash[:notice] = "Horas actualizadas"
      update_internal_cost(eq.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = eq.id
            render :json => json
          else
            redirect_to eq
          end
        end
      end

    else

      flash[:error] = "Error al actualizar horas"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = eq.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to eq
          end
        end
      end
    end

  end

  def equipment_table
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first
    render :layout => false
  end

  def delete_eq

    flash = {}
    eq = RequestedServiceEquipment.find(params[:eq_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if eq.destroy
      flash[:notice] = "Equipo eliminado"
      update_internal_cost(eq.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = eq.id
            render :json => json
          else
            redirect_to eq
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el equipo."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = eq.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to eq
          end
        end
      end
    end
    
  end

  def new_material
    
    flash = {}
    
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first

    mat =  @requested_service.requested_service_materials.new 
    the_mat = Material.find(params[:mat_id])
    mat.material_id = the_mat.id
    mat.quantity = params[:quantity]
    mat.unit_price = the_mat.unit_price

    if mat.save
      flash[:notice] = "Material agregado"
      update_internal_cost(params[:id])

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar el material."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  
  def update_mat_qty
    
    flash = {}
    mat = RequestedServiceMaterial.find(params[:mat_id])
    
    mat.quantity = params[:quantity]

    if mat.save
      flash[:notice] = "Cantidad actualizada"
      update_internal_cost(mat.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = mat.id
            render :json => json
          else
            redirect_to mat
          end
        end
      end

    else

      flash[:error] = "Error al actualizar la cantidad"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = mat.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to mat
          end
        end
      end
    end

  end

  def materials_table
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first
    render :layout => false
  end

  def delete_mat

    flash = {}
    mat = RequestedServiceMaterial.find(params[:mat_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if mat.destroy
      flash[:notice] = "Material eliminado"
      update_internal_cost(mat.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = mat.id
            render :json => json
          else
            redirect_to mat
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el material."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = mat.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to mat
          end
        end
      end
    end
    
  end


  def new_other
    
    flash = {}
    
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first

    other =  @requested_service.requested_service_others.new 
    other.other_type_id = params[:other_type_id]
    other.concept = params[:concept]
    other.price = params[:price]

    if other.save
      flash[:notice] = "Otro concepto agregado"
      update_internal_cost(params[:id])

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:sample_id] = @requested_service.sample_id
            json[:id] = @requested_service.id
            render :json => json
          else
            redirect_to @requested_service
          end
        end
      end

    else

      flash[:error] = "Error al agregar otro."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @requested_service.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @requested_service
          end
        end
      end
    end

  end

  
  def update_other_price
    
    flash = {}
    other = RequestedServiceOther.find(params[:other_id])
    
    other.price = params[:price]

    if other.save
      flash[:notice] = "Concepto actualizado"
      update_internal_cost(other.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
              json[:id] = other.id
            render :json => json
          else
            redirect_to other
          end
        end
      end

    else

      flash[:error] = "Error al actualizar el concepto"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = other.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to other
          end
        end
      end
    end

  end

  def others_table
    @requested_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => params[:id]}).first
    render :layout => false
  end

  def delete_other

    flash = {}
    other = RequestedServiceOther.find(params[:other_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if other.destroy
      flash[:notice] = "Concepto eliminado"
      update_internal_cost(other.requested_service.laboratory_service.id)

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = other.id
            render :json => json
          else
            redirect_to other
          end
        end
      end

    else

      flash[:error] = "Error al eliminar el concepto."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = other.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to other
          end
        end
      end
    end
    
  end

end
