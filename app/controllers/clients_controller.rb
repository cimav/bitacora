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

end
