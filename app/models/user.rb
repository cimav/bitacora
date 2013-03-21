class User < ActiveRecord::Base
  # attr_accessible :title, :body
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

  has_many :service_request
  has_many :laboratory_members
  has_many :requested_service
  has_many :requested_service_technicians
  has_many :laboratories, :through => :laboratory_members
  has_many :laboratory_services, :through => :requested_service
  has_many :activity_log

  def full_name
    "#{first_name} #{last_name}"
  end

  def access_text
    ACCESS_TYPES[access.to_i]
  end

  def can_create_external_services?
    access.to_i == ACCESS_ADMIN || access.to_i == ACCESS_CUSTOMER_SERVICE
  end


  def is_admin?
    access.to_i == ACCESS_ADMIN
  end

end
