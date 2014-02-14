class AddCodeToSample < ActiveRecord::Migration
  def change
    add_column :samples, :code, :string
  end
end
