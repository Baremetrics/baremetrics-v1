class SorceryBruteForceProtection < ActiveRecord::Migration
  def self.up
    add_column :accounts, :failed_logins_count, :integer, :default => 0
    add_column :accounts, :lock_expires_at, :datetime, :default => nil
    add_column :accounts, :unlock_token, :string, :default => nil
  end

  def self.down
    remove_column :accounts, :lock_expires_at
    remove_column :accounts, :failed_logins_count
    remove_column :accounts, :unlock_token
  end
end