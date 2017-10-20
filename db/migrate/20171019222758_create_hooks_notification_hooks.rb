class CreateHooksNotificationHooks < ActiveRecord::Migration
  def change
    create_table :hooks_notification_hooks do |t|
      t.string :name
    end
  end
end
