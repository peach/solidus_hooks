class CreateObserverEvents < ActiveRecord::Migration
  def change
    create_table :observer_events do |t|
      t.string  :name
      t.string  :target_name
      t.text    :triggers, default: '{}'

      t.timestamps
    end
  end
end
