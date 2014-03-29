class AddSystemIdToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :system_id, :integer
  end
end
