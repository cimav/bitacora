# coding: utf-8
class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id, :request_link

  has_many :sample
  belongs_to :request_type

  after_create :add_extra

  def add_extra
    self.sample.create(identification: 'Muestra 1', consecutive: 1, description: 'Sin descripción')
  end

end
