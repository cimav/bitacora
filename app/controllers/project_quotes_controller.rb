# coding: utf-8
require 'resque-bus'
class ProjectQuotesController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def show
    @project_quote = ProjectQuote.find(params['id'])
    @grand_total = get_grand_total(params[:id])
    render :layout => false
  end

  def get_grand_total(id)
    grand_total = RequestedService.find_by_sql(["SELECT IFNULL(SUM(subtotal),0) AS total FROM (
                                                   SELECT SUM(hours * hourly_rate) AS subtotal 
                                                     FROM project_quote_equipments 
                                                     WHERE project_quote_id = :project_quote
                                                     GROUP BY project_quote_id 
                                                   UNION 
                                                     SELECT SUM(hours * hourly_wage) AS subtotal 
                                                     FROM project_quote_technicians 
                                                     WHERE project_quote_id = :project_quote
                                                     GROUP BY project_quote_id
                                                   UNION
                                                     SELECT SUM(price) AS subtotal 
                                                     FROM project_quote_others 
                                                     WHERE project_quote_id = :project_quote
                                                     GROUP BY project_quote_id
                                                 ) subtotals", :project_quote => id]).first.total
  end

  def grand_total
    @grand_total = get_grand_total(params[:id])
    render :layout => false
  end

  def new_technician
    
    flash = {}

    @project_quote = ProjectQuote.find(params[:id])

    tech =  @project_quote.project_quote_technicians.new 
    user = User.find(params[:user_id])
    tech.user_id = params[:user_id]
    tech.hours = params[:tech_hours]
    tech.hourly_wage = user.hourly_wage

    if tech.save
      flash[:notice] = "Participante agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @project_quote.id
            render :json => json
          else
            redirect_to @project_quote
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
            json[:errors] = @project_quote.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @project_quote
          end
        end
      end
    end
  end


  def update_hours
    
    flash = {}
    tech = ProjectQuoteTechnician.find(params[:tech_id])
    
    tech.hours = params[:hours]

    if tech.save
      flash[:notice] = "Horas actualizadas"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = tech.id
            json[:project_quote_id] = tech.project_quote_id
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
    @project_quote = ProjectQuote.find(params[:id])
    render :layout => false
  end

  def delete_tech

    flash = {}
    tech = ProjectQuoteTechnician.find(params[:tech_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if tech.destroy
      flash[:notice] = "Participante eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = tech.id
            json[:project_quote_id] = tech.project_quote_id
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
    
    @project_quote = ProjectQuote.find(params[:id])

    eq =  @project_quote.project_quote_equipment.new 
    the_eq = Equipment.find(params[:eq_id])
    eq.equipment_id = params[:eq_id]
    eq.hours = params[:eq_hours]
    if @project_quote.service_request.is_vinculacion?
      eq.hourly_rate = the_eq.hourly_rate
    else
      eq.hourly_rate = the_eq.internal_hourly_rate
    end

    if eq.save
      flash[:notice] = "Equipo agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @project_quote.id
            render :json => json
          else
            redirect_to @project_quote
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
            json[:errors] = @project_quote.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @project_quote
          end
        end
      end
    end

  end

  
  def update_eq_hours
    
    flash = {}
    eq = ProjectQuoteEquipment.find(params[:eq_id])
    
    eq.hours = params[:hours]

    if eq.save
      flash[:notice] = "Horas actualizadas"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = eq.id
            json[:project_quote_id] = eq.project_quote_id
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
    @project_quote = ProjectQuote.find(params[:id])
    render :layout => false
  end

  def delete_eq

    flash = {}
    eq = ProjectQuoteEquipment.find(params[:eq_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if eq.destroy
      flash[:notice] = "Equipo eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = eq.id
            json[:project_quote_id] = eq.project_quote_id
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


  def new_other
    
    flash = {}
    
    @project_quote = ProjectQuote.find(params[:id])

    other =  @project_quote.project_quote_others.new 
    other.other_type_id = params[:other_type_id]
    other.concept = params[:concept]
    other.price = params[:price]

    if other.save
      flash[:notice] = "Otro concepto agregado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @project_quote.id
            render :json => json
          else
            redirect_to @project_quote
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
            json[:errors] = @project_quote.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @project_quote
          end
        end
      end
    end

  end

  
  def update_other_price
    
    flash = {}
    other = ProjectQuoteOther.find(params[:other_id])
    
    other.price = params[:price]

    if other.save
      flash[:notice] = "Concepto actualizado"

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
    @project_quote = ProjectQuote.find(params[:id])
    render :layout => false
  end

  def delete_other

    flash = {}
    other = ProjectQuoteOther.find(params[:other_id])
    # TODO: Validar que el tecnico que esta haciendo el borrado sea el dueño del servicio
    if other.destroy
      flash[:notice] = "Concepto eliminado"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = other.id
            json[:project_quote_id] = other.project_quote_id
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
