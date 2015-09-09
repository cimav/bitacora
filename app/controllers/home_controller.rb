class HomeController < ApplicationController
  before_filter :auth_required

  def index
    #Resque.workers.each {|w| w.unregister_worker}

    #Resque.queues.each do |queue_name|
    #  Resque.remove_queue("#{queue_name}")
    #end

  end

  def redirect_requested_service
    requested_service = RequestedService.where("number = :number", {:number => params[:number]}).first

    url = ''
    lab_access = requested_service.laboratory_service.laboratory.laboratory_members.where(:user_id => current_user.id).first.access rescue 0
    if lab_access.to_i != 0
      url = "/#!/laboratory/#{requested_service.laboratory_service.laboratory_id}/s/#{requested_service.id}"
    else 
      url = "/#!/service_requests/#{requested_service.sample.service_request_id}?s=#{requested_service.id}"
    end

    redirect_to url
    return
  end

   def redirect_service_request
    service_request = ServiceRequest.where("number = :number", {:number => params[:number]}).first 
    url = "/#!/service_requests/#{service_request.id}"
    redirect_to url
   end

end


# 15/0776-S001-001-01
# service_requests/6382
# requested-service-link-36292

#   http://yoshimi.cimav.edu.mx:3000/E150082-001-01