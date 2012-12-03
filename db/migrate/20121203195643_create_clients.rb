class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string     :name
      t.references :client_type
      t.string     :rfc
      t.string     :address1
      t.string     :address2
      t.string     :city
      t.references :state
      t.references :country
      t.string     :phone
      t.string     :fax
      t.string     :email
      t.integer    :status, :default => 1
      t.timestamps
    end
    add_index('clients', 'client_type_id')
    add_index('clients', 'state_id')
    add_index('clients', 'country_id')
  end
end
