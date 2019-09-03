class AddLegendToServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :legend, :text
    add_column :requested_services, :legend, :text
  end
end
