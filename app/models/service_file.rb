class ServiceFile < ActiveRecord::Base
  attr_accessible :file, :description, :user_id, :service_request_id, :sample_id, :requested_service_id, :file_type

  mount_uploader :file, ServiceFileUploader
  validates :description, :presence => true

  before_destroy :delete_linked_file

  FILE         = 99
  FINAL_REPORT = 1

  TYPES = {
    FILE         => 'Documento', 
    FINAL_REPORT => 'Reporte Final'
  }

  def type_text
    TYPES[file_type]
  end

  def delete_linked_file
    self.remove_file!
  end

end
