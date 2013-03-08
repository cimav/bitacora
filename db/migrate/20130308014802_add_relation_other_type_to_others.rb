class AddRelationOtherTypeToOthers < ActiveRecord::Migration
  def change
    remove_column :requested_service_others, :other_type
    add_column :requested_service_others, :other_type_id, :integer
  end
end
