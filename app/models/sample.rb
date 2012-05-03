class Sample < ActiveRecord::Base
  attr_accessible :identification, :description, :status, :consecutive, :service_request_id

  belongs_to :service_request
  has_many :requested_service

  after_create :set_consecutive

  def set_consecutive
    con = Sample.where(:service_request_id => self.service_request_id).maximum('consecutive')
    if con.nil?
      con = 1
    else 
      con += 1
    end
    consecutive = "%03d" % con
    self.consecutive = con
    self.number = "#{self.service_request.number}-#{consecutive}" 
    self.save(:validate => false)
  end
end
