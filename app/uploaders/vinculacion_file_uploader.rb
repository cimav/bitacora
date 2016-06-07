# encoding: utf-8

class VinculacionFileUploader < CarrierWave::Uploader::Base
  def store_dir
    "#{Rails.root}/../sigre/private/solicitud/#{model.solicitud_id}/archivos/"
  end
end
