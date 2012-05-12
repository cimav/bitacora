# encoding: utf-8

class ServiceFileUploader < CarrierWave::Uploader::Base
 storage :file

  def store_dir
    "#{RAILS_ROOT}/private/files/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
