class RequestedService < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sample
end
