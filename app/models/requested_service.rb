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
  after_create :create_files_dir
  after_create :set_system_based_status

  CANCELED       = -1
  INITIAL        = 1
  RECEIVED       = 2
  ASSIGNED       = 3
  SUSPENDED      = 4
  REINIT         = 5
  IN_PROGRESS    = 6
  REQ_SUP_AUTH   = 7
  REQ_OWNER_AUTH = 8

  TO_QUOTE       = 21
  WAITING_START  = 22

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

    TO_QUOTE       => 'Costeando',
    WAITING_START  => 'Se envio costeo',

    FINISHED       => 'Finalizado'
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
    if self.sample_id == 0
      self.consecutive = 0
      self.number = "TEMPLATE"
    else
      self.consecutive = con
      self.number = "#{self.sample.number}-#{consecutive}"
    end
    self.save(:validate => false)
  end

  def set_auth_if_needed
    if self.sample_id != 0
      u = User.find(self.sample.service_request.user_id)
      if u.require_auth?
        self.status = REQ_SUP_AUTH
        self.save(:validate => false)
      end
    end
  end

  def set_costs
    template_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => self.laboratory_service_id}).first
    if template_service.blank? || self.sample_id == 0
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
    # template_service.requested_service_materials.each do |mat|
    #   new_mat = self.requested_service_materials.new
    #   new_mat.material_id = mat.material_id
    #   the_mat = Material.find(mat.material_id)
    #   new_mat.quantity = mat.quantity
    #   new_mat.unit_price = the_mat.unit_price
    #   new_mat.details = mat.details
    #   new_mat.save
    # end

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

  def create_files_dir
    FileUtils.mkdir_p "#{Rails.root}/private/laboratories/#{self.laboratory_service.laboratory_id}/servicios/#{self.number}"
  end

  def set_system_based_status
    st = self.sample.service_request.system_status
    if st == ServiceRequest::SYSTEM_TO_QUOTE ||
       st == ServiceRequest::SYSTEM_PARTIAL_QUOTED ||
       st == ServiceRequest::SYSTEM_QUOTED

      self.status = TO_QUOTE
      self.save(:validate => false)

      if st == ServiceRequest::SYSTEM_QUOTED
        sr = self.sample.service_request
        sr.system_status = ServiceRequest::SYSTEM_PARTIAL_QUOTED
        sr.save(:validate => false)
      end

    end
  end

  def icon_class
    icon = 'glyphicon-home'     if status.to_i == INITIAL
    icon = 'glyphicon-inbox'    if status.to_i == RECEIVED
    icon = 'glyphicon-user'     if status.to_i == ASSIGNED
    icon = 'glyphicon-minus'    if status.to_i == SUSPENDED
    icon = 'glyphicon-repeat'   if status.to_i == REINIT
    icon = 'glyphicon-cog'      if status.to_i == IN_PROGRESS
    icon = 'glyphicon-ok'       if status.to_i == FINISHED
    icon = 'glyphicon-remove'   if status.to_i == CANCELED
    icon = 'glyphicon-lock'     if status.to_i == REQ_SUP_AUTH
    icon = 'glyphicon-lock'     if status.to_i == REQ_OWNER_AUTH
    icon = 'glyphicon-list-alt' if status.to_i == TO_QUOTE
    icon = 'glyphicon-time'     if status.to_i == WAITING_START
    icon
  end

  def status_class
    st = 'status-initial'     if status.to_i == INITIAL
    st = 'status-received'    if status.to_i == RECEIVED
    st = 'status-assigned'    if status.to_i == ASSIGNED
    st = 'status-suspended'   if status.to_i == SUSPENDED
    st = 'status-reinit'      if status.to_i == REINIT
    st = 'status-in-progress' if status.to_i == IN_PROGRESS
    st = 'status-finished'    if status.to_i == FINISHED
    st = 'status-canceled'    if status.to_i == CANCELED
    st = 'status-auth'        if status.to_i == REQ_SUP_AUTH
    st = 'status-auth'        if status.to_i == REQ_OWNER_AUTH
    st = 'status-to-quote'    if status.to_i == TO_QUOTE
    st = 'status-waiting'     if status.to_i == WAITING_START
    st
  end

end
