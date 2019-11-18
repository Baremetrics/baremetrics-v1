class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :account
      t.text :event_id
      t.boolean :livemode
      t.text :event_type
      t.text :data
      t.text :object
      t.timestamps
    end
  end
end
