class AddQuantityToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :quantity, :integer
    Sample.update_all ["quantity = 1"]
  end
end
