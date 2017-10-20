class CreateEventsHooks < ActiveRecord::Migration
  def change
    create_join_table :events, :hooks
  end
end
