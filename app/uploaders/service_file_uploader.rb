# encoding: utf-8

class ServiceFileUploader < CarrierWave::Uploader::Base
 storage :file

  def store_dir
    if model.requested_service_id == 0 
      "#{Rails.root}/public/laboratories/0/servicios/#{model.service_request.number}"
    else 
      "#{Rails.root}/public/laboratories/#{model.requested_service.laboratory_service.laboratory_id}/servicios/#{model.requested_service.number}"
    end
  end
end
