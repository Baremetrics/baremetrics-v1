class SorceryResetPassword < ActiveRecord::Migration
  def self.up
    add_column :accounts, :reset_password_token, :string, :default => nil
    add_column :accounts, :reset_password_token_expires_at, :datetime, :default => nil
    add_column :accounts, :reset_password_email_sent_at, :datetime, :default => nil
    
    add_index :accounts, :reset_password_token
  end

  def self.down
    remove_index :accounts, :reset_password_token
    
    remove_column :accounts, :reset_password_email_sent_at
    remove_column :accounts, :reset_password_token_expires_at
    remove_column :accounts, :reset_password_token
  end
end