class CreateExternalRequests < ActiveRecord::Migration
  def change
    create_table :external_requests do |t|
      t.references :service_request
      t.date       :request_date
      t.string     :service_number
      t.boolean    :is_acredited
      t.text       :client_agreements
      t.text       :notes
      t.timestamps
    end
  end
end
