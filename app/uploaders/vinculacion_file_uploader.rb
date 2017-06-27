# encoding: utf-8

class VinculacionFileUploader < CarrierWave::Uploader::Base

  def filename
    original_filename.gsub(/ /i,'_').gsub(/[^\.a-z0-9_]/i, '') if original_filename
  end

  def store_dir
    "#{Rails.root}/../sigre/private/solicitud/#{model.solicitud_id}/archivos/"
  end
end
