class HomeController < ApplicationController
  before_filter :auth_required

  def index
    #Resque.workers.each {|w| w.unregister_worker}
  end

  def redirect_requested_service
    # requested_service = RequestedService.where("number = :number", {:number => params[:number]}).first

    # url = ''

    # if current_user.id == requested_service.laboratory_service.laboratory.user_id ||
    #    current_user.id == requested_service.user_id
    #   url = "/#!/laboratory/#{requested_service.laboratory_service.laboratory_id}?r=#{requested_service.number}"
    # else 
    #   url = "/#!/folders?r=#{requested_service.number}" 
    # end

    # redirect_to url
    # return
  end

end
