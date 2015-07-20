require 'rake'

class String
  def red;   "\033[31m#{self}\033[0m" end
  def green; "\033[32m#{self}\033[0m" end
end

task :addsampledetails => :environment do |t, args|
  puts "Add details to samples..."
  Sample.all.each do |s|
    puts "#{s.number}: #{s.quantity} samples"
    for i in 1..s.quantity
      sd = s.sample_details.new
      sd.consecutive = i
      sd.save
      puts "Detail #{i} created".green
    end
  end
end
