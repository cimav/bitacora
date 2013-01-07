class ClientContactsController < ApplicationController

  respond_to :html, :xml, :json

  def combo
    @client_contacts = ClientContact.where("client_id = :id", {:id => params[:client_id].to_i}).order(:name)
    render :layout => false
  end

  def new_dialog
    @client = Client.find(params[:client_id])
    render :layout => false
  end

  def create
    @client_contact = ClientContact.new(params[:client_contact])

    flash = {}
    if @client_contact.save
      flash[:notice] = "Contacto agregado."

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @client_contact.id
            json[:name] = @client_contact.name
            json[:client_id] = @client_contact.client_id
            render :json => json
          else
            redirect_to @client_contact
          end
        end
      end
    else
      flash[:error] = "Error al crear el contacto."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @client_contact.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @client_contact
          end
        end
      end
    end
  end

end
