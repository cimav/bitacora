# coding: utf-8
class ServiceRequest < ActiveRecord::Base
  attr_accessible :request_type_id, :description, :user_id, :request_link, :sample_attributes, :supervisor_id, :external_request_attributes

  has_many :external_request
  accepts_nested_attributes_for :external_request

  has_many :activity_log

  has_many :sample
  accepts_nested_attributes_for :sample

  belongs_to :request_type
  belongs_to :user
  belongs_to :supervisor, :class_name => 'User', :foreign_key => 'supervisor_id'

  after_create :add_extra

  ACTIVE = 1
  DELETED = 2
  
  IMPORTED = 98

  def add_extra
    con = ServiceRequest.where("number LIKE :prefix AND YEAR(created_at) = :year", {:prefix => "#{self.request_type.prefix}%", :year => Date.today.year}).maximum('consecutive')
    if con.nil?
      con = 1
    else
      con += 1
    end
    consecutive = "%04d" % con
    self.consecutive = con
    year = Date.today.year.to_s.last(2)
    self.number = "#{self.request_type.prefix}#{year}#{consecutive}"
    self.save(:validate => false)
  end

end
