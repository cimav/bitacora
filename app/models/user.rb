class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :access, :employee_number, :status, :supervisor1_id, :supervisor2_id, :require_auth, :business_unit_id
  STATUS_ACTIVE    = 1
  STATUS_INACTIVE  = 2
  STATUS_SUSPENDED = 3

  ACCESS_STUDENT          = 1
  ACCESS_INTERNSHIP       = 2
  ACCESS_PROJECT_EMPLOYEE = 3
  ACCESS_EMPLOYEE         = 4
  ACCESS_CUSTOMER_SERVICE = 5
  ACCESS_ADMIN            = 99

  ACCESS_TYPES = {
    ACCESS_STUDENT          => 'Estudiante',
    ACCESS_INTERNSHIP       => 'Servicio o Post-Doctorado',
    ACCESS_PROJECT_EMPLOYEE => 'Por proyecto',
    ACCESS_EMPLOYEE         => 'Empleado',
    ACCESS_CUSTOMER_SERVICE => 'Servicio al cliente',
    ACCESS_ADMIN            => 'Administrador',
  }

  STATUS_TYPES = {
    STATUS_ACTIVE => "Activo",
    STATUS_INACTIVE => "Baja",
    STATUS_SUSPENDED => "Suspendido"
  }

  has_many :service_request
  has_many :laboratory_members
  has_many :requested_service
  has_many :requested_service_technicians
  has_many :laboratories, :through => :laboratory_members
  has_many :laboratory_services, :through => :requested_service
  has_many :activity_log
  has_many :collaborations
  belongs_to :supervisor1, :class_name => 'User', :foreign_key => 'supervisor1_id'
  belongs_to :supervisor2, :class_name => 'User', :foreign_key => 'supervisor2_id'

  def full_name
    "#{first_name} #{last_name}"
  end

  def access_text
    ACCESS_TYPES[access.to_i]
  end

  def status_text
    STATUS_TYPES[status.to_i]
  end

  def can_create_external_services?
    access.to_i == ACCESS_ADMIN || access.to_i == ACCESS_CUSTOMER_SERVICE
    true
  end

  def is_customer_service?
    access.to_i == ACCESS_ADMIN || access.to_i == ACCESS_CUSTOMER_SERVICE
  end


  def is_admin?
    access.to_i == ACCESS_ADMIN
  end

  def avatar_url
    "http://cimav.edu.mx/foto/#{email.split('@')[0]}/64"
  end

end
