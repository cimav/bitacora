class ChangeOtherTypeToId < ActiveRecord::Migration
  def change
    rename_column :project_quote_others, :other_type, :other_type_id
  end
end
