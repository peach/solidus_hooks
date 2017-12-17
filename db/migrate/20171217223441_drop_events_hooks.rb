class DropEventsHooks < ActiveRecord::Migration
  def change
    drop_join_table :events, :hooks
  end
end
