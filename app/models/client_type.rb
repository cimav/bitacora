class ClientType < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :clients
end
