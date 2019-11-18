class CleanUpUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_4_digits
    remove_column :users, :company
    remove_column :users, :phone
    remove_column :users, :stripe_access_token
    remove_column :users, :stripe_publishable_key
    remove_column :users, :stripe_account_id
    remove_column :users, :stripe_livemode
    remove_column :users, :stripe_connected_at

    add_column :users, :account_id, :integer
    add_index :users, :account_id
  end
end
