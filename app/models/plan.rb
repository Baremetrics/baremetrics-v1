class Plan < ActiveRecord::Base
  has_many :accounts

  attr_accessible :title, :permalink, :api_handle, :price, :feature_customers, :feature_users, :feature_email_reports, :active, :feature_compare_biz
end
