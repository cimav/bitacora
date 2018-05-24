#coding:utf-8
desc "Manda un email recordando los mantenimientos"
task :maintenances => :environment do
  today = Date.today
  
  # Mantenimientos que vencen en 2 meses
  maintenances = Maintenance.where(status: Maintenance::STATUS_PROGRAMMED, expected_date: today + 2.month)
  maintenances.each do |m|
    BitacoraMailer.maintenance_reminder(m, "Mantenimiento programado dentro de 2 meses para #{m.equipment.name}").deliver
  end

  # Mantenimientos que vencen en 1 mes
  maintenances = Maintenance.where(status: Maintenance::STATUS_PROGRAMMED, expected_date: today + 1.month)
  maintenances.each do |m|
    BitacoraMailer.maintenance_reminder(m, "Mantenimiento programado dentro de 1 mes para #{m.equipment.name}").deliver
  end

  # Mantenimientos que vencen en 2 semanas
  maintenances = Maintenance.where(status: Maintenance::STATUS_PROGRAMMED, expected_date: today + 2.weeks)
  maintenances.each do |m|
    BitacoraMailer.maintenance_reminder(m, "Mantenimiento programado dentro de 2 semanas para #{m.equipment.name}").deliver
  end

  # Mantenimientos que vencen en 1 semanas
  maintenances = Maintenance.where(status: Maintenance::STATUS_PROGRAMMED, expected_date: today + 1.weeks)
  maintenances.each do |m|
    BitacoraMailer.maintenance_reminder(m, "Mantenimiento programado dentro de 1 semana para #{m.equipment.name}").deliver
  end

  # Mantenimientos vencidos
  maintenances = Maintenance.where('status = ? AND expected_date < ?', Maintenance::STATUS_PROGRAMMED, today)
  maintenances.each do |m|
    BitacoraMailer.maintenance_reminder(m, "IMPORTANTE: El mantenimiento programado no ha sido realizado para #{m.equipment.name}").deliver
  end
end

