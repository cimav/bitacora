class AdminController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json
  
  def index
  	render :layout => false
  end

  def users
    render :layout => false
  end
  
  def departments
    render :layout => false
  end

  def laboratories
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

  def request_types
    render :layout => false
  end

  def service_types
    render :layout => false
  end

  def other_types
    render :layout => false
  end

  def providers
    render :layout => false
  end

end
