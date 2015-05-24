class AddServiceQuoteTypeToRequestedServices < ActiveRecord::Migration
  def change
    add_column :requested_services, :service_quote_type, :integer
  end
end
