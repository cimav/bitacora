# coding: utf-8
class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id, :request_link, :sample_attributes

  has_many :sample
  accepts_nested_attributes_for :sample

  belongs_to :request_type

  after_create :add_extra

  def add_extra
    self.number = "%04d" % [self.id]
    self.save() 
    self.sample.create(identification: 'Muestra 1', description: 'Sin descripción')
  end

end
