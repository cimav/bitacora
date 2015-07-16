class GenerateSampleZip
  @queue = :zip

  def self.perform(sample_id)
    sample = Sample.find(sample_id)
    sample_number = sample.number.gsub("/","_")
    req_services = RequestedService.where(:sample_id => sample_id)
    temp = Tempfile.new("zip-file-#{Time.now}")
    Zip::ZipOutputStream.open(temp.path) do |z|
      req_services.each do |rs|
        rs.service_files.where(:status => ServiceFile::ACTIVE).each do |service_file|
          z.put_next_entry(File.basename(service_file.file.to_s))
          z.print File.open(service_file.file.to_s, "rb"){ |f| f.read }
        end
      end
    end
    FileUtils.mkdir_p "#{Rails.root}/public/zip/#{sample.code}"
    FileUtils.cp(temp.path, "#{Rails.root}/public/zip/#{sample.code}/#{sample_number}.zip")
    temp.delete()
  end

end
