class SampleDetail < ActiveRecord::Base
  attr_accessible :consecutive, :client_identification, :notes, :status

  belongs_to :sample


end
