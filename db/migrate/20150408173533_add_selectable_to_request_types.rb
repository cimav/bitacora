class AddSelectableToRequestTypes < ActiveRecord::Migration
  def change
    add_column :request_types, :is_selectable, :integer, :default => 0
  end
end
