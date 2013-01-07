class ClientsController < ApplicationController

  respond_to :html, :xml, :json

  def typeahead

    clients = Client.where("name LIKE :q", {:q => "%#{params[:query]}%"})
    options = []
    clients.each do |c|
      options << c.name
    end

    respond_with do |format|
      format.html do
        if request.xhr?
          json = {}
          json[:options] = options
          render :json => json
        end
      end
    end
  end

  def info
    @client = Client.where("name LIKE :q", {:q => "%#{params[:query]}%"}).first
    render :layout => false
  end

  def new_dialog
    render :layout => false
  end

  def create
    @client = Client.new(params[:client])

    flash = {}
    if @client.save
      flash[:notice] = "Cliente agregado."

      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @client.id
            json[:name] = @client.name
            render :json => json
          else
            redirect_to @client
          end
        end
      end
    else
      flash[:error] = "Error al crear cliente."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @client.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @client
          end
        end
      end
    end
  end


end
