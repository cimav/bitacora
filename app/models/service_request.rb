# coding: utf-8
class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id, :request_link, :sample_attributes

  has_many :activity_log

  has_many :sample
  accepts_nested_attributes_for :sample

  belongs_to :request_type
  belongs_to :user

  after_create :add_extra

  def add_extra
    self.number = "%04d" % [self.id]
    self.save() 
  end

end
