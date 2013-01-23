class AddParticipationToRequestedServiceTechnicians < ActiveRecord::Migration
  def change
    add_column :requested_service_technicians, :participation, :integer
  end
end
