class Alert < ActiveRecord::Base
  attr_accessible :message_type, :message, :user_id, :laboratory_service_id, :technician, :equipment_id, :status, :start_date, :end_date

  belongs_to :user
  belongs_to :laboratory_service
  belongs_to :equipment
  belongs_to :technician, :class_name => 'User', :foreign_key => 'technician' 


  OPEN = 1
  RESOLVED = 99

  STATUS = {
    OPEN      => 'Abierta',
    RESOLVED  => 'Resuelta'
  }

  def status_text
    STATUS[status.to_i]
  end
end
