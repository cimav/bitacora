class AddQuoteNeedsAuthToLaboratory < ActiveRecord::Migration
  def change
  	add_column :laboratories, :quote_needs_auth, :boolean, :default => 0
  end
end
