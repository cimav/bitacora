class Maintenance < ActiveRecord::Base

  attr_accessible :equipment_id, :provider_id, :name, :expected_date, :real_date, :description
  belongs_to :equipment
  belongs_to :provider
  has_many :activity_log


  STATUS_PROGRAMMED  = 1
  STATUS_IN_PROCCESS = 2
  STATUS_DONE        = 3
  STATUS_CANCELED    = 99
  STATUS_DELETED     = -1

  STATUS_TYPES = {
    STATUS_PROGRAMMED  => 'Programado',
    STATUS_IN_PROCCESS => 'En proceso',
    STATUS_DONE   => 'Realizado',
    STATUS_CANCELED => 'Cancelado',
    STATUS_DELETED => 'Eliminado',
  }

  def status_text
    STATUS_TYPES[status.to_i]
  end

end
