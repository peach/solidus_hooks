class CreateObserverEventDependencies < ActiveRecord::Migration[5.0]
  def change
    create_table :observer_event_dependencies do |t|
      t.references  :event
      t.references  :dependent_event
      t.string      :association_name

      t.timestamps
    end
  end
end
