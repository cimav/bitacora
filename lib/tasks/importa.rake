require 'rake'

class String
  def red;   "\033[31m#{self}\033[0m" end
  def green; "\033[32m#{self}\033[0m" end
end

task :importa, [:filename] => :environment do |t, args|
  pwd = Dir.pwd
  filename = "#{pwd}/#{args[:filename]}"
  importado_id = RequestType.where(:short_name => 'IMPORTADO').first.id
  puts "Importando #{filename}"
  File.open(filename, "r").each_line do |line|
    service, qty, month, day, requestor, technician, log = line.split('|')

    puts "Buscar requisitor #{requestor}"
    if u_requestor = User.where("email LIKE '#{requestor}@%'").first

      lab_service = LaboratoryService.find(service)

      # Crear service requests Importados (si no existe)

      if folder = u_requestor.service_request.where(:request_type_id => importado_id).first
        puts "Folder #{folder.number}"
      else 
        puts "Creando service_request..."
        folder = u_requestor.service_request.new 
        folder.request_type_id = importado_id
        folder.request_link = "Agosto 2013"
        folder.description = "Servicios importados"
        folder.save
      end


      # Crear muestra si no existe para el lab.
      if muestra = folder.sample.where(:identification => lab_service.laboratory.prefix).first
        puts "Muestra #{muestra.id}:#{muestra.identification}"
      else 
        muestra = folder.sample.new
        muestra.identification = lab_service.laboratory.prefix
        muestra.description = "Servicios importados del laboratorio #{lab_service.laboratory.name}"
        muestra.status = 1
        muestra.quantity = 1
        muestra.save
      end

      # Agregar el servicio a la muestra
      if u_tech = User.where("email LIKE '#{technician}@%'").first
        for i in 1..qty.to_i
          serv = muestra.requested_service.new
          serv.user_id = u_tech.id
          serv.suggested_user_id = u_tech.id
          serv.status = RequestedService::FINISHED
          serv.created_at = "2013-#{month}-#{day} 0:00"
          serv.updated_at = "2013-#{month}-#{day} 0:00"
          serv.laboratory_service_id = lab_service.id
          if qty == 1
            serv.details = "Muestra importada"
          else
            serv.details = "Muestra importada (1/#{i})"
          end
          serv.save
 
          # Agregar comentarios en activity_log
          serv.activity_log.create(user_id: u_tech.id,
                                   service_request_id: serv.sample.service_request_id,
                                   sample_id: serv.sample_id,
                                   message_type: 'MESSAGE',
                                   requested_service_status: RequestedService::FINISHED,
                                   message: "Servicio Importado. #{log}")

          puts "Servicio #{lab_service.name} importado para tecnico #{u_tech.full_name}"
        end
      end

    else
      puts "No se encontro el requisitor #{requestor}".red
    end     
    puts "-----------------------------------------------------------------------"
  end
end
