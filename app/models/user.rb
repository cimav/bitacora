class User < ActiveRecord::Base
  # attr_accessible :title, :body
  STATUS_ACTIVE    = 1
  STATUS_INACTIVE  = 2
  STATUS_SUSPENDED = 3

  ACCESS_STUDENT          = 1
  ACCESS_INTERNSHIP       = 2
  ACCESS_PROJECT_EMPLOYEE = 3
  ACCESS_EMPLOYEE         = 4
  ACCESS_ADMIN            = 99

  has_many :service_request
  has_many :laboratory_members
  has_many :laboratories, :through => :laboratory_members
  has_many :activity_log

  def full_name
    "#{first_name} #{last_name}"
  end
end
