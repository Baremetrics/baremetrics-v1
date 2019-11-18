class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.text :last_4_digits
      t.text :company
      t.text :phone
      t.text :stripe_access_token
      t.text :stripe_publishable_key
      t.text :stripe_account_id
      t.text :stripe_livemode
      t.datetime :stripe_connected_at
      t.timestamps
    end
  end
end
