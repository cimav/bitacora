# coding: utf-8
class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id, :request_link, :sample_attributes, :supervisor_id

  has_one :external_service

  has_many :activity_log

  has_many :sample
  accepts_nested_attributes_for :sample

  belongs_to :request_type
  belongs_to :user
  belongs_to :supervisor, :class_name => 'User', :foreign_key => 'supervisor_id'

  after_create :add_extra

  ACTIVE = 1
  DELETED = 2

  def add_extra
    self.number = "%04d" % [self.id]
    self.save() 
  end

end
