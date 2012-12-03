class CreateClientContacts < ActiveRecord::Migration
  def change
    create_table :client_contacts do |t|
      t.references :client
      t.string     :name
      t.string     :phone
      t.string     :email
      t.integer    :status, :default => 1
      t.timestamps
    end
    add_index('client_contacts', 'client_id')
  end
end
