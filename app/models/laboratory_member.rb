class LaboratoryMember < ActiveRecord::Base
  attr_accessible :user_id, :status, :access, :laboratory_id
  belongs_to :laboratory
  belongs_to :user

  ACCESS_MEMBER   = 1
  ACCESS_TRAINED  = 2
  ACCESS_ADMIN    = 99

  ACCESS_TYPES = {
    ACCESS_MEMBER  => 'Miembro',
    ACCESS_TRAINED => 'Facultado',
    ACCESS_ADMIN   => 'Administrador'
  }

  ACTIVE = 1
  INACTIVE = 2

  def access_text
    ACCESS_TYPES[access.to_i]
  end
end
