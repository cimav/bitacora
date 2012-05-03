class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|

      t.timestamps
    end
  end
end
