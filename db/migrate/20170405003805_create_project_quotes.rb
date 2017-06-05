class CreateProjectQuotes < ActiveRecord::Migration
  def change
    create_table :project_quotes do |t|
      t.references :service_request
      t.integer    :consecutive
      t.string     :number, :limit => 20
      t.text       :details
      t.timestamps null: false
    end
  end
end
