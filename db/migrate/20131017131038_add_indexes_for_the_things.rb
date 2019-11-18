class AddIndexesForTheThings < ActiveRecord::Migration
  def change
    add_index :events, :event_id, :unique => true
    add_index :events, :account_id
    add_index :events, :event_type
    add_index :events, [:event_type, :created_at]
    add_index :stats, :method_name
    add_index :stats, :method_key
    add_index :stats, :account_id
    add_index :stats, [:account_id, :method_name, :method_key, :occurred_on], :name => 'index_stat_account_method_name_key_occurred'
    add_index :accounts, :stripe_access_token
    add_index :accounts, :stripe_publishable_key
  end
end
