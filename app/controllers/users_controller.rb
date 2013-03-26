class UsersController < ApplicationController
  before_filter :auth_required
  respond_to :html, :json

  def new
    @user = User.new
    render :layout => false
  end

  def edit
    @user = User.find(params[:id])
    render :layout => false
  end

  def live_search
    @users = User.where('status = :s', {:s => User::STATUS_ACTIVE}).order('first_name, last_name')
    if !params[:search_user_type].blank? && params[:search_user_type] != '0'
      @users = @users.where("access = :c", {:c => params[:search_user_type]}) 
    end
    if !params[:q].blank?
      @users = @users.where("(CONCAT(first_name,' ',last_name) LIKE :q)", {:q => "%#{params[:q]}%"})
    end
    render :layout => false
  end

  def update
    @user = User.find(params[:id])

    flash = {}

    if @user.update_attributes(params[:user])
      flash[:notice] = "Usuario actualizado"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @user.id
            json[:name] = @user.full_name
            render :json => json
          else
            redirect_to @user
          end
        end
      end
    else
      flash[:error] = "Error al actualizar el usuario."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @user.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @user
          end
        end
      end
    end
  end

  def create
    @user = User.new

    flash = {}

    if @user.update_attributes(params[:user])
      flash[:notice] = "Usuario creado"
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:id] = @user.id
            json[:name] = @user.full_name
            render :json => json
          else
            redirect_to @user
          end
        end
      end
    else
      flash[:error] = "Error al crear el usuario."
      respond_with do |format|
        format.html do
          if request.xhr?
            json = {}
            json[:flash] = flash
            json[:errors] = @user.errors
            render :json => json, :status => :unprocessable_entity
          else
            redirect_to @user
          end
        end
      end
    end
  end  
end
