class AddStripeCustomerToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :stripe_customer_id, :text
  end
end
