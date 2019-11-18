class AddStripeConnectedAt < ActiveRecord::Migration
  def change
    add_column :accounts, :stripe_connected_at, :datetime
  end
end
