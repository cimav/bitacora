class LaboratoryImage < ActiveRecord::Base
  attr_accessible :file, :description, :user_id, :laboratory_id

  belongs_to :laboratory
  belongs_to :user

  mount_uploader :file, LaboratoryImageUploader

  def delete_linked_file
    self.remove_file!
  end

end
