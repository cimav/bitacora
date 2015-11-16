class Alert < ActiveRecord::Base
  attr_accessible :message_type, :message, :user_id, :laboratory_service_id, :technician, :equipment_id, :status, :start_date, :end_date

  belongs_to :user
  belongs_to :laboratory_service
  belongs_to :equipment
  belongs_to :technician, :class_name => 'User', :foreign_key => 'technician' 

  after_create :add_extra


  OPEN = 1
  SOLVED = 99

  STATUS = {
    OPEN      => 'Abierta',
    SOLVED  => 'Resuelta'
  }

  def status_text
    STATUS[status.to_i]
  end

  def add_extra
    if self.start_date.blank?
      self.start_date = self.created_at
    end
    self.save
  end

end
