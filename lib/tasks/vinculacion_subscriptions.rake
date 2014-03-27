class VinculacionSubscriptions
  include ResqueBus::Subscriber

  subscribe :solicitar_costeo

  def solicitar_costeo(attributes)
    puts "------------------"
    puts " SOLICITAR COSTEO "
    puts "------------------"
    # TODO: Create service_request
   
    # Add samples to service_request   
    attributes['muestras'].each do |m|
      # TODO: Add sample
    end
  end
end
