class AddRequireAuthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :require_auth, :boolean, :default => 0
  end
end
