class CreateServiceRequestParticipations < ActiveRecord::Migration
  def change
    create_table :service_request_participations do |t|
      t.references :service_request
      t.references :user
      t.integer    :percentage
      t.timestamps
    end
  end
end
