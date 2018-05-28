class Substance < ActiveRecord::Base

  attr_accessible :laboratory_id, :name, :quantity, :description, :container, :expire_date, :status, :user_id

  belongs_to :laboratory 

  STATUS_AVAILABLE  = 1
  STATUS_DELETED     = -1

  STATUS_TYPES = {
    STATUS_AVAILABLE  => 'Disponible'
  }

  def status_text
    STATUS_TYPES[status.to_i]
  end
end
