# encoding: utf-8

class ServiceFileUploader < CarrierWave::Uploader::Base
 storage :file

  def store_dir
    "#{Rails.root}/private/files/#{model.id}"
  end
end
