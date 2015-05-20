class AddSuggestedPriceToServiceRequests < ActiveRecord::Migration
  def change
    add_column :equipment, :suggested_price, :decimal, :precision => 10, :scale => 2
  end
end
