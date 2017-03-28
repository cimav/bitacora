class Laboratory < ActiveRecord::Base
  attr_accessible :name, :business_unit_id, :prefix, :description, :user_id
  has_many :laboratory_requests
  has_many :laboratory_services
  has_many :laboratory_members
  has_many :laboratory_images
  has_many :laboratory_service_classifications
  has_many :equipment
  belongs_to :user
  belongs_to :business_unit
  has_many :users, :through => :laboratory_members
  has_many :requested_services, :through => :laboratory_services

  after_create :add_super_member

  ACTIVE = 1
  INACTIVE = 2

  def add_super_member
    m = self.laboratory_members.new
    m.user_id = self.user_id
    m.access = LaboratoryMember::ACCESS_ADMIN
    m.save
  end

end
