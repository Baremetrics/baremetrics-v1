# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131120194644) do

  create_table "accounts", :force => true do |t|
    t.text     "last_4_digits"
    t.text     "company"
    t.text     "phone"
    t.text     "stripe_access_token"
    t.text     "stripe_publishable_key"
    t.text     "stripe_account_id"
    t.text     "stripe_livemode"
    t.datetime "stripe_connected_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.datetime "last_synced"
    t.integer  "plan_id"
    t.text     "stripe_customer_id"
    t.boolean  "active",                 :default => true
  end

  create_table "authentications", :force => true do |t|
    t.integer  "account_id", :null => false
    t.string   "provider",   :null => false
    t.string   "uid",        :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "account_id"
    t.text     "event_id"
    t.boolean  "livemode"
    t.text     "event_type"
    t.text     "data"
    t.text     "object"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "events", ["account_id"], :name => "index_events_on_account_id"
  add_index "events", ["event_id"], :name => "index_events_on_event_id", :unique => true
  add_index "events", ["event_type", "created_at"], :name => "index_events_on_event_type_and_created_at"
  add_index "events", ["event_type"], :name => "index_events_on_event_type"

  create_table "plans", :force => true do |t|
    t.string   "title"
    t.string   "permalink"
    t.string   "api_handle"
    t.decimal  "price"
    t.integer  "feature_customers"
    t.integer  "feature_users"
    t.boolean  "feature_email_reports", :default => false
    t.boolean  "feature_compare_biz",   :default => false
    t.boolean  "active",                :default => true
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "stats", :force => true do |t|
    t.integer  "account_id"
    t.text     "method_name"
    t.text     "method_key"
    t.text     "data"
    t.date     "occurred_on"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "stats", ["account_id", "method_name", "method_key", "occurred_on"], :name => "index_stat_account_method_name_key_occurred"
  add_index "stats", ["account_id"], :name => "index_stats_on_account_id"
  add_index "stats", ["method_key"], :name => "index_stats_on_method_key"
  add_index "stats", ["method_name"], :name => "index_stats_on_method_name"

  create_table "users", :force => true do |t|
    t.string   "email",                                              :null => false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
    t.integer  "failed_logins_count",             :default => 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
    t.text     "first_name"
    t.text     "last_name"
    t.integer  "account_id"
    t.boolean  "admin",                           :default => false
    t.boolean  "reports_daily",                   :default => false
    t.boolean  "reports_weekly",                  :default => false
    t.boolean  "reports_monthly",                 :default => false
    t.boolean  "change_password",                 :default => false
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"
  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_accounts_on_last_logout_at_and_last_activity_at"
  add_index "users", ["remember_me_token"], :name => "index_accounts_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_accounts_on_reset_password_token"

end
