class Sample < ActiveRecord::Base
  attr_accessible :identification, :description, :status, :consecutive, :service_request_id, :quantity, :sample_details_attributes

  belongs_to :service_request
  has_many :requested_service
  has_many :activity_log
  has_many :sample_details

  after_create :set_consecutive
  after_create :set_code
  after_create :set_sample_details

  accepts_nested_attributes_for :sample_details

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

  def set_code
    self.code = SecureRandom.hex(8)
    self.save(:validate => false)
  end

  def set_sample_details
    if self.service_request.request_type_id != ServiceRequest::SERVICIO_VINCULACION && self.service_request.request_type_id != ServiceRequest::SERVICIO_VINCULACION_NO_COORDINADO && self.service_request.request_type_id != ServiceRequest::SERVICIO_VINCULACION_TIPO_2
      for i in 1..self.quantity
        sd = self.sample_details.new
        sd.consecutive = i
        sd.client_identification = ''
        sd.notes = ''
        sd.save
      end
    end
  end


end
