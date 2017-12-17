class AddEventableToObserverEvents < ActiveRecord::Migration
  def up
    change_table :observer_events do |t|
      t.references :eventable, polymorphic: true
    end
  end

  def down
    change_table :observer_events do |t|
      t.remove_references :eventable, polymorphic: true
    end
  end
end
