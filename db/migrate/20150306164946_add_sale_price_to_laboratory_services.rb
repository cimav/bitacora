class AddSalePriceToLaboratoryServices < ActiveRecord::Migration
  def change
    add_column :laboratory_services, :sale_price, :decimal, :precision => 10, :scale => 2
  end
end
