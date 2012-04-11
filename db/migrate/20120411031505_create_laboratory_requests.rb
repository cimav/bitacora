class CreateLaboratoryRequests < ActiveRecord::Migration
  def change
    create_table :laboratory_requests do |t|
      t.references :user
      t.string     :request_number, :limit => 20
      t.integer    :consecutive
      t.references :laboratory
      t.references :request_type
      t.string     :request_link
      t.text       :description
      t.integer    :responsible
      t.integer    :status, :default => 1
      t.datetime   :request_date
      t.datetime   :end_date
      t.timestamps
    end
    add_index('laboratory_requests', 'user_id')
    add_index('laboratory_requests', 'request_type_id')
    add_index('laboratory_requests', 'laboratory_id')
    add_index('laboratory_requests', 'responsible')
  end
end
