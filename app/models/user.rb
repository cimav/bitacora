class User < ActiveRecord::Base
  # attr_accessible :title, :body
  STATUS_ACTIVE = 1
  STATUS_INACTIVE = 2
  STATUS_SUSPENDED = 3
end
