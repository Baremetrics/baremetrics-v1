class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string  "title"
      t.string  "permalink"
      t.string  "api_handle"
      t.decimal "price"
      t.integer "feature_customers"
      t.integer "feature_users"
      t.boolean "feature_email_reports", :default => false
      t.boolean "feature_compare_biz", :default => false
      t.boolean "active",      :default => true
      t.timestamps
    end
  end
end
