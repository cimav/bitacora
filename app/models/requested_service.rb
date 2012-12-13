# coding: utf-8
class RequestedService < ActiveRecord::Base
  attr_accessible :laboratory_service_id, :sample_id, :details, :status, :suggested_user_id, :user_id
  belongs_to :user
  belongs_to :suggested_user, :class_name => 'User', :foreign_key => 'suggested_user_id' 
  belongs_to :sample
  belongs_to :laboratory_service
  has_many :activity_log

  after_create :set_consecutive

  CANCELED     = -1
  INITIAL      = 1
  RECEIVED     = 2
  ASSIGNED     = 3
  SUSPENDED    = 4
  REINIT       = 5
  IN_PROGRESS  = 6
  FINISHED     = 99 

  STATUS = {
    INITIAL      => 'Inicio',
    RECEIVED     => 'Muestra Recibida',
    ASSIGNED     => 'Técnico Asignado',
    SUSPENDED    => 'Servicio Suspendido',
    REINIT       => 'Servicio Reiniciado',
    CANCELED     => 'Servicio Cancelado',
    IN_PROGRESS  => 'En Progreso',
    FINISHED     => 'Finalizado'
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

  def icon_class
    icon = 'icon-asterisk' if status.to_i == INITIAL
    icon = 'icon-check'    if status.to_i == RECEIVED
    icon = 'icon-user'     if status.to_i == ASSIGNED
    icon = 'icon-minus'    if status.to_i == SUSPENDED
    icon = 'icon-repeat'   if status.to_i == REINIT
    icon = 'icon-play'     if status.to_i == IN_PROGRESS
    icon = 'icon-ok'       if status.to_i == FINISHED
    icon = 'icon-remove'   if status.to_i == CANCELED
    icon
  end

end
