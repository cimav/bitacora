class LoginController < ApplicationController
  def index
    render :layout => 'login'
  end

  def set_user
    puts params[:email]
    set_current_user(params[:email])
    redirect_to "/"
  end

end
