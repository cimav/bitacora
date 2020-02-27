class AddPresupuestoEnviadoToServiceRequest < ActiveRecord::Migration
  def change
    add_column :service_requests, :presupuesto_enviado, :boolean, :default => false
  end
end
