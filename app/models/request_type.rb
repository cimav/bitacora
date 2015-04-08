class RequestType < ActiveRecord::Base
  attr_accessible :short_name, :name, :is_selectable, :prefix
  has_many :service_request

  IS_NOT_SELECTABLE = 0
  IS_SELECTABLE = 1
end
