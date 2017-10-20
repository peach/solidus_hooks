class CreateNotificationLogs < ActiveRecord::Migration
  def change
    create_table :notification_logs do |t|
      t.integer :event_id
      t.integer :record_id
      t.string :target_model
      t.integer :notification_hook_id

      t.timestamps null: false
    end
  end
end
