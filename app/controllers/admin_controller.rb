class AdminController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  
  def index
  	render :layout => false
  end

  def clients
  	render :layout => false
  end

  def equipment
  	render :layout => false
  end

  def materials
    render :layout => false
  end

end
