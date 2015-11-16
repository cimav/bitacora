class LaboratoryService < ActiveRecord::Base
  attr_accessible :name, :description, :service_type_id, :laboratory_id, :internal_cost, :is_catalog, :sale_price, :is_exclusive_vinculacion, :status
  belongs_to :laboratory
  has_many :requested_service
  has_many :alerts
  has_many :users, :through => :requested_service
  belongs_to :service_type

  validates :name, :presence => true
  validates :service_type_id, :presence => true
  validates :laboratory_id, :presence => true

  after_create :create_template

  SERVICE_FREE = 0
  SERVICE_CATALOG = 1

  SERVICE_FOR_ALL = 0
  SERVICE_EXCLUSIVE = 1

  STATUS_ACTIVE = 0
  STATUS_INACTIVE = 1

  def create_template
    template = self.requested_service.new
    template.sample_id = 0
    template.consecutive = 0
    template.number = 'TEMPLATE'
    template.details = ''
    template.user_id = self.laboratory.user_id
    template.save(:validate => false)
  end
  
end
