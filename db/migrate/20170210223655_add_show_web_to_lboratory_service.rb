class AddShowWebToLboratoryService < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :show_web, :boolean, :default => 0
  end
end
