class CreateHooksWebHooks < ActiveRecord::Migration
  def change
    create_table :hooks_web_hooks do |t|
      t.string :name
      t.string :url
      t.string :listener_token

      t.timestamps
    end
  end
end
