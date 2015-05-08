class AddBudgetItemAndPurchaseDateAndPurchasePriceToEquipment < ActiveRecord::Migration
  def change
    add_column :equipment, :budget_item, :string
    add_column :equipment, :purchase_date, :date
    add_column :equipment, :purchase_price, :decimal, :precision => 10, :scale => 2
    add_column :equipment, :internal_hourly_rate, :decimal, :precision => 10, :scale => 2
  end
end
