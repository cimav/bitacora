class Client < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :client_type
  belongs_to :country
  belongs_to :state
end
