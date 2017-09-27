class CreateEventsHooks < ActiveRecord::Migration[5.0]
  def change
    create_join_table :events, :hooks
  end
end
