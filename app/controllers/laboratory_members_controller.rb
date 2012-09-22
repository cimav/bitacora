class LaboratoryMembersController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def create
    @laboratory_member = LaboratoryMember.new(params[:laboratory_member])
    flash = {}
    if (@laboratory_member.save)
      flash[:notice] = "Miembro de laboratorio agregado satisfactoriamente (#{@laboratory_member.id})"

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:id] = @laboratory_member.id
            json[:name] = @laboratory_member.user.last_name
            json[:flash] = flash
            render :json => json
          else
            render :inline => "Esta accion debe ser accesada via XHR"
          end
        end
      end
    else
      flash[:error] = "No se pudo agregar el miembro"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_member.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_member
          end
        end
      end
    end
  end

  def edit
    @laboratory_member = LaboratoryMember.find(params[:id])
    render :layout => false
  end

  def update
    @laboratory_member = LaboratoryMember.find(params[:id])

    flash = {}
    if @laboratory_member.update_attributes(params[:laboratory_member])
      flash[:notice] = "Miembro actualizado."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            render :json => json
          else
            redirect_to @laboratory_member
          end
        end
      end
    else
      flash[:error] = "Error al actualizar miembro"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @laboratory_member.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @laboratory_member
          end
        end
      end
    end
  end

end
