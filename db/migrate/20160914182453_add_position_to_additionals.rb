class AddPositionToAdditionals < ActiveRecord::Migration
  def change
    add_column :requested_service_additionals, :position, :integer, :default => 0
    add_column :laboratory_service_additionals, :position, :integer, :default => 0
  end
end
