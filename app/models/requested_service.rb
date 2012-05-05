# coding: utf-8
class RequestedService < ActiveRecord::Base
  attr_accessible :laboratory_service_id, :sample_id, :details
  belongs_to :sample
  belongs_to :laboratory_service
  has_many :activity_log

  after_create :set_consecutive

  INITIAL   = 1
  RECEIVED  = 2
  ASSIGNED  = 3
  SUSPENDED = 4
  REINIT    = 5
  CANCELED  = 6
  PROGRESS  = 7
  FINISH    = 99 

  STATUS = {
    INITIAL   => 'Inicio',
    RECEIVED  => 'Muestra Recibida',
    ASSIGNED  => 'Técnico Asignado',
    SUSPENDED => 'Servicio Suspendido',
    REINIT    => 'Servicio Reiniciado',
    CANCELED  => 'Servicio Cancelado',
    PROGRESS  => 'En Progreso'
  }

  def status_text
    STATUS[status.to_i]
  end

  def set_consecutive
    con = RequestedService.where(:sample_id => self.sample_id).maximum('consecutive')
    if con.nil?
      con = 1
    else
      con += 1
    end
    consecutive = "%02d" % con
    self.consecutive = con
    self.number = "#{self.sample.number}-#{consecutive}"
    self.save(:validate => false)
  end

end
