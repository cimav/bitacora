class ServiceFile < ActiveRecord::Base
  attr_accessible :file, :description, :user_id, :service_request_id, :sample_id, :requested_service_id, :file_type_id

  mount_uploader :file, ServiceFileUploader
  validates :description, :presence => true

  before_destroy :delete_linked_file

  def delete_linked_file
    self.remove_file!
  end

end
