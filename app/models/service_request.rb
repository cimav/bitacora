# coding: utf-8
class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id, :request_link, :sample_attributes, :supervisor_id, :external_request_attributes, :suggested_price, :estimated_time

  has_many :external_request
  accepts_nested_attributes_for :external_request

  has_many :activity_log

  has_many :sample
  accepts_nested_attributes_for :sample

  has_many :requested_services, through: :sample

  has_many :service_request_participations

  belongs_to :request_type
  belongs_to :user
  belongs_to :supervisor, :class_name => 'User', :foreign_key => 'supervisor_id'

  has_many :collaborators

  after_create :add_extra

  ACTIVE = 1
  DELETED = 2
  
  IMPORTED = 98

  SERVICIO_VINCULACION = 1
  SERVICIO_VINCULACION_NO_COORDINADO = 12
  SERVICIO_VINCULACION_TIPO_2 = 14

  SYSTEM_FREE              = 1
  SYSTEM_TO_QUOTE          = 2
  SYSTEM_PARTIAL_QUOTED    = 3
  SYSTEM_QUOTED            = 4
  SYSTEM_QUOTE_SENT        = 5
  SYSTEM_ACCEPTED          = 6
  SYSTEM_SAMPLES_DELIVERED = 7
  SYSTEM_PARTIAL_FINISHED  = 8
  SYSTEM_ALL_FINISHED      = 9
  SYSTEM_REPORT_SENT       = 10
  SYSTEM_IN_PROGRESS       = 11
  SYSTEM_NOT_ACCEPTED      = 98
  SYSTEM_CANCELED          = 99

  SYSTEM_STATUS = {
    SYSTEM_FREE              => 'Libre',
    SYSTEM_TO_QUOTE          => 'Por costear',
    SYSTEM_PARTIAL_QUOTED    => 'Algunos servicios costeados',
    SYSTEM_QUOTED            => 'Costeado, listo para enviar costeo a Vinculación',
    SYSTEM_QUOTE_SENT        => 'Costeo enviado a Vinculación, en espera de aceptación del cliente',
    SYSTEM_ACCEPTED          => 'Costeo aceptado por el cliente',
    SYSTEM_SAMPLES_DELIVERED => 'Muestras entregadas',
    SYSTEM_PARTIAL_FINISHED  => 'Algunos servicios finalizados',
    SYSTEM_ALL_FINISHED      => 'Servicios finalizados, falta enviar reporte',
    SYSTEM_REPORT_SENT       => '✓ Reporte enviado a Vinculación',
    SYSTEM_NOT_ACCEPTED      => 'No aceptado por cliente',
    SYSTEM_CANCELED          => 'Cancelado',
    SYSTEM_IN_PROGRESS       => 'En progreso'
  }

  def system_status_text
    SYSTEM_STATUS[system_status.to_i]
  end

  def add_extra
    # If is not Servicio Vinculacion then create number
    if (self.request_type_id != SERVICIO_VINCULACION && self.request_type_id != SERVICIO_VINCULACION_NO_COORDINADO && self.request_type_id != SERVICIO_VINCULACION_TIPO_2) || self.number.nil?
      con = ServiceRequest.where("number LIKE :prefix AND YEAR(created_at) = :year", {:prefix => "#{self.request_type.prefix}%", :year => Date.today.year}).maximum('consecutive')
      if con.nil?
        con = 1
      else
        con += 1
      end
      consecutive = "%04d" % con
      self.system_status = SYSTEM_FREE
      self.consecutive = con
      year = Date.today.year.to_s.last(2)
      self.number = "#{self.request_type.prefix}#{year}#{consecutive}"
      self.save(:validate => false)
    end
  end

end
