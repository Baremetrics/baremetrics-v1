class AddActiveToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :active, :boolean, default: true
  end
end
