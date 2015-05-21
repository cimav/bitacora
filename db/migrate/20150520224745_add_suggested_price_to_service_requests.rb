class AddSuggestedPriceToServiceRequests < ActiveRecord::Migration
  def change
    add_column :service_requests, :suggested_price, :decimal, :precision => 10, :scale => 2
  end
end
