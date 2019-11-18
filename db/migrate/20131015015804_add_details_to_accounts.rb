class AddDetailsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :first_name, :text
    add_column :accounts, :last_name, :text
    add_column :accounts, :last_4_digits, :text
    add_column :accounts, :company, :text
    add_column :accounts, :phone, :text
    add_column :accounts, :stripe_access_token, :text
    add_column :accounts, :stripe_publishable_key, :text
    add_column :accounts, :stripe_account_id, :text
    add_column :accounts, :stripe_livemode, :text
  end
end
