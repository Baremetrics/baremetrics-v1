class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.references :account
      t.text :method_name
      t.text :method_key # plan_white_label_monthly_trial_199_customers
      t.text :data
      t.date :occurred_on
      t.timestamps
    end
  end
end