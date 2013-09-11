class AddPrefixToRequestTypes < ActiveRecord::Migration
  def change
    add_column :request_types, :prefix, :string
  end
end
