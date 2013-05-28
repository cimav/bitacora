# coding: utf-8
class RequestedService < ActiveRecord::Base
  attr_accessible :laboratory_service_id, :sample_id, :details, :status, :suggested_user_id, :user_id, :from_id
  belongs_to :user
  belongs_to :suggested_user, :class_name => 'User', :foreign_key => 'suggested_user_id' 
  belongs_to :sample
  belongs_to :laboratory_service
  has_many :activity_log
  has_many :service_files

  has_many :requested_service_technicians
  has_many :requested_service_equipments
  has_many :requested_service_materials
  has_many :requested_service_others

  after_create :set_consecutive
  after_create :set_auth_if_needed
  after_create :set_costs

  CANCELED       = -1
  INITIAL        = 1
  RECEIVED       = 2
  ASSIGNED       = 3
  SUSPENDED      = 4
  REINIT         = 5
  IN_PROGRESS    = 6
  REQ_SUP_AUTH   = 7
  REQ_OWNER_AUTH = 8
  FINISHED       = 99 

  STATUS = {
    INITIAL        => 'Inicio',
    RECEIVED       => 'Muestra Recibida',
    ASSIGNED       => 'Técnico Asignado',
    SUSPENDED      => 'Servicio Suspendido',
    REINIT         => 'Servicio Reiniciado',
    CANCELED       => 'Servicio Cancelado',
    IN_PROGRESS    => 'En Progreso',
    REQ_SUP_AUTH   => 'Aut. de supervisor',
    REQ_OWNER_AUTH => 'Aut. de solicitante',
    FINISHED     => 'Finalizado'
  }

  def status_text
    STATUS[status.to_i]
  end

  def set_consecutive
    con = RequestedService.where(:sample_id => self.sample_id).maximum('consecutive')
    if con.nil?
      con = 1
    else
      con += 1
    end
    consecutive = "%02d" % con
    self.consecutive = con
    self.number = "#{self.sample.number}-#{consecutive}"
    self.save(:validate => false)
  end

  def set_auth_if_needed
    u = User.find(self.sample.service_request.user_id)
    if u.require_auth?
      self.status = REQ_SUP_AUTH
      self.save(:validate => false)
    end
  end

  def set_costs
    template_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => self.laboratory_service_id}).first
    if template_service.blank?
      return false
    end

    # Technicians
    template_service.requested_service_technicians.each do |tech|
      new_tech = self.requested_service_technicians.new
      new_tech.user_id = tech.user_id
      user_tech = User.find(tech.user_id)
      new_tech.hours = tech.hours
      new_tech.hourly_wage = user_tech.hourly_wage
      new_tech.details = tech.details
      new_tech.participation = tech.participation
      new_tech.save
    end

    # Equipment
    template_service.requested_service_equipments.each do |eq|
      new_eq = self.requested_service_equipments.new
      new_eq.equipment_id = eq.equipment_id
      the_eq = Equipment.find(eq.equipment_id)
      new_eq.hours = eq.hours
      new_eq.hourly_rate = the_eq.hourly_rate
      new_eq.details = eq.details
      new_eq.save
    end
    
    # Material
    template_service.requested_service_materials.each do |mat|
      new_mat = self.requested_service_materials.new
      new_mat.material_id = mat.material_id
      the_mat = Material.find(mat.material_id)
      new_mat.quantity = mat.quantity
      new_mat.unit_price = the_mat.unit_price
      new_mat.details = mat.details
      new_mat.save
    end
    
    # Other
    template_service.requested_service_others.each do |other|
      new_other = self.requested_service_others.new
      new_other.concept = other.concept
      new_other.price = other.price
      new_other.details = other.details
      new_other.other_type_id = other.other_type_id
      new_other.save
    end
  end

  def icon_class
    icon = 'icon-asterisk' if status.to_i == INITIAL
    icon = 'icon-check'    if status.to_i == RECEIVED
    icon = 'icon-user'     if status.to_i == ASSIGNED
    icon = 'icon-minus'    if status.to_i == SUSPENDED
    icon = 'icon-repeat'   if status.to_i == REINIT
    icon = 'icon-play'     if status.to_i == IN_PROGRESS
    icon = 'icon-ok'       if status.to_i == FINISHED
    icon = 'icon-remove'   if status.to_i == CANCELED
    icon = 'icon-lock'     if status.to_i == REQ_SUP_AUTH
    icon = 'icon-lock'     if status.to_i == REQ_OWNER_AUTH
  end

end
