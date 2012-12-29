class ClientContact < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :client
  belongs_to :external_request
end
