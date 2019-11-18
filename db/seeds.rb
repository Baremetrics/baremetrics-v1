# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Plan.create(title:'Hobby',permalink:'hobby',api_handle:'hobby_monthly_29',price: 29.00, feature_customers: 200, feature_users: 1, feature_email_reports: false, feature_compare_biz: false)

Plan.create(title:'Startup',permalink:'startup',api_handle:'startup_monthly_79',price: 79.00, feature_customers: 1000, feature_users: 3, feature_email_reports: true, feature_compare_biz: false)

Plan.create(title:'Professional',permalink:'professional',api_handle:'professional_monthly_149',price: 149.00, feature_customers: 2000, feature_users: 5, feature_email_reports: true, feature_compare_biz: false)

Plan.create(title:'Business',permalink:'business',api_handle:'business_monthly_249',price: 249.00, feature_customers: 4000, feature_users: 10, feature_email_reports: true, feature_compare_biz: true)

Plan.create(title:'VIP',permalink:'vip',api_handle:'vip',price: 0.00, feature_customers: 10000, feature_users: 0, feature_email_reports: true, feature_compare_biz: true)