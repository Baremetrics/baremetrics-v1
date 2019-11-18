class AddLastRunToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :last_synced, :datetime, default: nil
  end
end
