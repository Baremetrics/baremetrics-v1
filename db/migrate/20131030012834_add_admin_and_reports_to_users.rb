class AddAdminAndReportsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false
    add_column :users, :reports_daily, :boolean, default: false
    add_column :users, :reports_weekly, :boolean, default: false
    add_column :users, :reports_monthly, :boolean, default: false
    add_column :users, :change_password, :boolean, default: false
  end
end
