class ChangeLaboratoryServicesNameFromStringToText < ActiveRecord::Migration
  def up
    change_table :laboratory_services do |t|
      t.change :name, :text
    end
  end

  def down
    change_table :laboratory_services do |t|
      t.change :name, :string
    end
  end
end
