class ProjectQuote < ActiveRecord::Base
  belongs_to :service_request
  has_many   :project_quote_services
  has_many   :project_quote_technicians
  has_many   :project_quote_equipment
  has_many   :project_quote_others

  after_create :set_consecutive

  def set_consecutive
    con = ProjectQuote.where(:service_request => self.service_request_id).maximum('consecutive')
    if con.nil?
      con = 1
    else
      con += 1

      prev = ProjectQuote.where(:service_request => self.service_request_id, :consecutive => con - 1)

      # Services
      prev.project_quote_services.each do |serv|
        new_serv = self.project_quote_services.new
        new_serv.laboratory_service_id = serv.laboratory_service_id
        new_serv.quantity = serv.quantity
        new_serv.save
      end

      # Technicians
      prev.project_quote_technicians.each do |tech|
        new_tech = self.project_quote_technicians.new
        new_tech.user_id = tech.user_id
        user_tech = User.find(tech.user_id)
        new_tech.hours = tech.hours 
        new_tech.hourly_wage = user_tech.hourly_wage
        new_tech.details = tech.details
        new_tech.save
      end

      # Equipment
      prev.project_quote_equipments.each do |eq|
        new_eq = self.project_quote_equipments.new
        new_eq.equipment_id = eq.equipment_id
        the_eq = Equipment.find(eq.equipment_id)
        new_eq.hours = eq.hours * self.sample.quantity
        new_eq.hourly_rate = the_eq.hourly_rate
        new_eq.details = eq.details
        new_eq.save
      end

      # Other
      prev.project_quote_others.each do |other|
        new_other = self.project_quote_others.new
        new_other.concept = other.concept
        new_other.price = other.price
        new_other.quantity = other.quantity
        new_other.details = other.details
        new_other.other_type_id = other.other_type_id
        new_other.save
      end
      
    end
    consecutive = "%02d" % con
    self.consecutive = con
    self.number = "#{self.service_request.number}-C#{consecutive}"
    self.save(:validate => false)
  end

end
