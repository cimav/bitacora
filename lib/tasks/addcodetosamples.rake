require 'rake'

class String
  def red;   "\033[31m#{self}\033[0m" end
  def green; "\033[32m#{self}\033[0m" end
end

task :addcodetosamples => :environment do |t, args|
  puts "Add code to samples..."
  Sample.all.each do |s|
    s.code = SecureRandom.hex(8)
    puts "#{s.number} #{s.code}"
    if s.save    
      puts "OK".green
    else 
      puts "ERROR".red
    end
  end
end
