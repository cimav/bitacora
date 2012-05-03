# coding: utf-8
class RequestedService < ActiveRecord::Base
  attr_accessible :laboratory_service_id, :sample_id, :details
  belongs_to :sample
  belongs_to :laboratory_service

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
end
