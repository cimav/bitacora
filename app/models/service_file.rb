class ServiceFile < ActiveRecord::Base
  attr_accessible :file, :description, :user_id, :service_request_id, :sample_id, :requested_service_id, :file_type

  belongs_to :sample
  belongs_to :user
  belongs_to :requested_service 

  mount_uploader :file, ServiceFileUploader
  validates :description, :presence => true

  before_destroy :delete_linked_file

  ACTIVE = 1
  DELETED = 2

  FILE         = 99
  FINAL_REPORT = 1

  TYPES = {
    FILE         => 'Documento', 
    FINAL_REPORT => 'Reporte Final'
  }

  ICONS = {
    FILE         => 'icon-file', 
    FINAL_REPORT => 'icon-ok'
  }


  def type_text
    TYPES[file_type]
  end

  def file_type_icon
    ICONS[file_type]
  end

  def delete_linked_file
    self.remove_file!
  end

end
