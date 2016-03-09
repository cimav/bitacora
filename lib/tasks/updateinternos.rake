require 'rake'

class String
  def red;   "\033[31m#{self}\033[0m" end
  def green; "\033[32m#{self}\033[0m" end
end

task :updateinternos => :environment do |t, args|
  puts "Actualizar servicios internos con plantilla"
  rs = RequestedService.joins(:sample,:service_request).where('request_type_id NOT IN (1,12,14) AND YEAR(requested_services.created_at) >= 2015');
  c = 0
  puts "-----------------------------------------------------------------------"
  rs.each do |r|
    puts "PROCESANDO #{r.id}"
    c = c + 1
    tech_cost = 0
    eq_cost = 0
    other_cost = 0
    template_error = 'NO'
    tiene_datos_tech = 'NO'
    tiene_datos_eq = 'NO'
    tiene_datos_other = 'NO'
    template_service = RequestedService.where("(laboratory_service_id = :id AND sample_id = 0)", {:id => r.laboratory_service_id}).first
    if template_service.blank? || r.sample_id == 0
      template_error = 'No se encontro template'
    else
      # Technicians
      if r.requested_service_technicians.count > 0 
        tiene_datos_tech = 'SI'
        r.requested_service_technicians.each do |tech|
          tech_cost = tech_cost + (tech.hours * r.sample.quantity) * tech.hourly_wage
        end
      else
        template_service.requested_service_technicians.each do |tech|
          puts "TEC"
          tiene_datos_tech = 'TPL'
          user_tech = User.find(tech.user_id)
          tech_cost = tech_cost + (tech.hours * r.sample.quantity) * user_tech.hourly_wage
          
          new_tech = r.requested_service_technicians.new
          new_tech.user_id = tech.user_id
          new_tech.hours = tech.hours * r.sample.quantity
          new_tech.hourly_wage = user_tech.hourly_wage
          new_tech.details = tech.details
          new_tech.participation = tech.participation
          new_tech.save
        end
      end

      # Equipment
      if r.requested_service_equipments.count > 0 
        tiene_datos_eq = 'SI'
        r.requested_service_equipments.each do |eq|
          the_eq = Equipment.find(eq.equipment_id)
          eq_cost = eq_cost + (eq.hours * r.sample.quantity) * the_eq.internal_hourly_rate
        end
      else
        template_service.requested_service_equipments.each do |eq| 
          puts "EQ"
          tiene_datos_eq = 'TPL'
          the_eq = Equipment.find(eq.equipment_id)
          eq_cost = eq_cost + (eq.hours * r.sample.quantity) * the_eq.internal_hourly_rate

          new_eq = r.requested_service_equipments.new
          new_eq.equipment_id = eq.equipment_id        
          new_eq.hours = eq.hours * r.sample.quantity
          new_eq.hourly_rate = the_eq.internal_hourly_rate
          new_eq.details = eq.details
          new_eq.save

        end
      end

      # Other
      if r.requested_service_others.count > 0 
        tiene_datos_other = 'SI'
        r.requested_service_others.each do |other|
          other_cost = other_cost + (other.price * r.sample.quantity)
        end
      else
        template_service.requested_service_others.each do |other| 
          puts "OTHER"
          tiene_datos_other = 'TPL'
          other_cost = other_cost + (other.price * r.sample.quantity)

          new_other = r.requested_service_others.new
          new_other.concept = other.concept
          new_other.price = other.price * r.sample.quantity
          new_other.details = other.details
          new_other.other_type_id = other.other_type_id
          new_other.save

        end
      end

    end 
    puts "#{c}|#{r.id}|#{r.number}|#{r.sample.quantity}|#{r.laboratory_service_id}|#{tiene_datos_tech}|#{tech_cost}|#{tiene_datos_eq}|#{eq_cost}|#{tiene_datos_other}|#{other_cost}|#{template_error}"
  
  end
  
end

