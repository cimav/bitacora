require 'rake'

class String
  def red;   "\033[31m#{self}\033[0m" end
  def green; "\033[32m#{self}\033[0m" end
end

task :fixfiles => :environment do |t, args|

  tty_cols = 80

  puts "Create requested services directories"
  done = 0
  rs = RequestedService.all
  total = rs.count
  rs.each do |r|
    FileUtils.mkdir_p "#{Rails.root}/private/laboratories/#{r.laboratory_service.laboratory_id}/servicios/#{r.number}"
    done += 1
    percent = ((done.to_f / total) * 100).to_i
    print "\r"*tty_cols+"#{done}/#{total} | \e[1m#{percent}%\e[0m "
  end
  print "\n"

  puts "Move files to new location..."
  sf = ServiceFile.all
  total = sf.count
  done = 0
  sf.each do |s|
    filename = File.basename(s.file.to_s)
    old_path = "#{Rails.root}/private/files/#{s.id}/#{filename}"
    if File.file?(old_path) 
      FileUtils.mv old_path, s.file.to_s
    else
      puts "File not found #{old_path}".red
    end
    done += 1
    percent = ((done.to_f / total) * 100).to_i
    print "\r"*tty_cols+"#{done}/#{total} | \e[1m#{percent}%\e[0m "
  end
  print "\n"

  puts "Done".green

end
