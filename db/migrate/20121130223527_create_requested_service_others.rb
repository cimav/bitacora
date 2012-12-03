class CreateRequestedServiceOthers < ActiveRecord::Migration
  def change
    create_table :requested_service_others do |t|
      t.references :requested_service
      t.integer    :other_type
      t.string     :concept
      t.text       :details
      t.decimal    :price, :precision => 6, :scale => 2
      t.timestamps
    end
    add_index('requested_service_others', 'requested_service_id')
  end
end
