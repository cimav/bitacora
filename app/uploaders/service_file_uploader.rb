# encoding: utf-8

class ServiceFileUploader < CarrierWave::Uploader::Base
 storage :file

  def store_dir
    "#{Rails.root}/public/laboratories/#{model.requested_service.laboratory_service.laboratory_id}/servicios/#{model.requested_service.number}"
  end
end
