class Stat < ActiveRecord::Base
  attr_accessible :method_name, :method_key, :data, :occurred_on

  belongs_to :account

  def self.avg_daily_billed(time = false)
    if time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end
    arr = self.where(method_name: 'money.per_day').where(occurred_on: range).pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el } / range.count).to_f / 100
    else
      0
    end
  end

  def self.avg_daily_billed_plan(time = 1.month, plan)
    range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date

    arr = self.where(method_key: "money.#{plan}.per_day").where(occurred_on: range).pluck(:data).collect{|s| s.to_i}

    arr.present? ? ((arr.inject{ |sum, el| sum + el } / range.count).to_f / 100) : 0
  end

  def self.live_customer_count(plan)
    if where(method_key: "plan.#{plan['id']}.customers").first
      where(method_key: "plan.#{plan['id']}.customers").first.data.to_i
    else
      0
    end
  end

  def self.active_accounts(time = false)
    if time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'accounts.active', occurred_on: range).pluck(:data).collect{|s| s.to_i}
    arr.present? ? arr.inject{ |sum, el| sum + el } : 0
  end

  def self.active_accounts_plan(time = 1.month, plan)
    range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date

    arr = self.where(method_key: "accounts.#{plan}.active", occurred_on: range).pluck(:data).collect{|s| s.to_i}
    arr.inject{ |sum, el| sum + el }.to_i
  end

  def self.created_accounts(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'accounts.created', occurred_on: range).pluck(:data).collect{|s| s.to_i}

    arr.present? ? arr.inject{ |sum, el| sum + el } : 0
  end

  def self.cancelled_accounts(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'accounts.cancelled', occurred_on: range).pluck(:data).collect{|s| s.to_i}

    arr.present? ? arr.inject{ |sum, el| sum + el } : 0
  end

  def self.cancelled_accounts_plan(time = 1.month, plan)
    range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date

    arr = self.where(method_key: "accounts.#{plan}.cancelled", occurred_on: range).pluck(:data).collect{|s| s.to_i}
    arr.inject{ |sum, el| sum + el }
  end

  def self.cancelled_accounts_total
    arr = self.where(method_name: 'accounts.cancelled').pluck(:data).collect{|s| s.to_i}

    arr.present? ? arr.inject{ |sum, el| sum + el } : 0
  end

  def self.churn_rate(time = 1.month)
    if cancelled_accounts(time) > 0 and active_accounts(time) > 0
      (cancelled_accounts(time).to_f / active_accounts(time).to_f) * 100
    else
      0
    end
  end

  def self.churn_rate_avg(months = 6)
    arr = [churn_rate(1.month), churn_rate(2.month), churn_rate(3.month), churn_rate(4.month), churn_rate(5.month), churn_rate(6.month)]
    arr = arr.compact

    arr.delete_if do |arr|
      arr == 0
    end

    arr.size > 0 ? (arr.inject{ |sum, el| sum + el } / arr.size).to_f : 0
  end

  def self.churn_rate_plan(time = 1.month, plan)
    if cancelled_accounts_plan(time, plan).present? and active_accounts_plan(time, plan) > 0
      (cancelled_accounts_plan(time, plan).to_f / active_accounts_plan(time, plan).to_f) * 100
    else
      0
    end
  end

  def self.churn_rate_plan_rolling(months = 3, plan)
    arr = [churn_rate_plan(1.month, plan), churn_rate_plan(2.month, plan), churn_rate_plan(3.month, plan), churn_rate_plan(4.month, plan), churn_rate_plan(5.month, plan), churn_rate_plan(6.month, plan)]
    arr = arr.compact

    arr.delete_if do |arr|
      arr == 0
    end

    arr.size > 0 ? (arr.inject{ |sum, el| sum + el } / arr.size).to_f : 0
  end

  def self.ltv(time = 1.month)
    num_of_days = time.ago.end_of_month.day

    if avg_daily_billed(time) > 0 and active_accounts(time) > 0 and churn_rate(time).present?
      a = (avg_daily_billed(time).to_f / active_accounts(time).to_f) * num_of_days
      if churn_rate(time) == 0
        b = 100
      else
        b = 100 / churn_rate(time)
      end

      a * b
    else
      0
    end
  end

  def self.ltv_rolling(months = 6)
    arr = [ltv(1.month), ltv(2.month), ltv(3.month), ltv(4.month), ltv(5.month), ltv(6.month)]
    arr = arr.compact

    arr.delete_if do |arr|
      arr == 0
    end

    arr.size > 0 ? (arr.inject{ |sum, el| sum + el } / arr.size).to_f : 0
  end

  def self.ltv_plan(time = 1.month, plan)
    num_of_days = time.ago.end_of_month.day

    if avg_daily_billed_plan(time, plan) > 0 and active_accounts_plan(time, plan) > 0 and churn_rate_plan(time, plan).present?
      a = (avg_daily_billed_plan(time, plan).to_f / active_accounts_plan(time, plan).to_f) * num_of_days

      if churn_rate_plan(time, plan) == 0
        b = 100
      else
        b = 100 / churn_rate_plan(time, plan)
      end

      a * b
    else
      0
    end
  end

  def self.ltv_plan_rolling(months = 3, plan)
    arr = [ltv_plan(1.month, plan), ltv_plan(2.month, plan), ltv_plan(3.month, plan), ltv_plan(4.month, plan), ltv_plan(5.month, plan), ltv_plan(6.month, plan)]
    arr = arr.compact

    arr.delete_if do |arr|
      arr == 0
    end

    arr.size > 3 ? (arr.inject{ |sum, el| sum + el } / arr.size).to_f : 0
  end

  def self.total_gross_sales
    arr = self.where(method_name: 'charge.gross_sales').pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.gross_sales(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'charge.gross_sales', occurred_on: range).pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.total_refunds
    arr = self.where(method_name: 'charge.refunds').pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.total_fees
    arr = self.where(method_name: 'balance.fees').pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.fees(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'balance.fees', occurred_on: range).pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.refunds(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'charge.refunds', occurred_on: range).pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.total_gross_revenue
    total_gross_sales#- total_refunds
  end

  def self.gross_revenue(time = false)
    gross_sales(time)# - refunds(time)
  end

  def self.total_net_revenue
    total_gross_sales - total_refunds - total_fees
  end

  def self.net_revenue(time = false)
    gross_sales(time) - refunds(time) - fees(time)
  end

  def self.gross_revenue_by_plan(plan)
    arr = self.where(method_key: "charge.#{plan}.gross_sales").pluck(:data).collect{|s| s.to_i}
    (arr.inject{ |sum, el| sum + el }).to_f / 100
  end

  def self.fees_by_plan(plan)
    arr = self.where(method_key: "balance.#{plan}.fees").pluck(:data).collect{|s| s.to_i}
    (arr.inject{ |sum, el| sum + el }).to_f / 100
  end

  def self.mrr(time = false)
    if time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'charge.gross_sales', occurred_on: range).pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.mrr_average
    arr = [mrr(1.month), mrr(2.month), mrr(3.month)]
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end

  def self.arpu(time = false)
    if mrr(time).present? and active_accounts(time) > 0
      self.mrr(time) / self.active_accounts(time).to_i
    else
      0
    end
  end

  def self.revenue_growth_rate(time = false)
    previous_time = time ? time + 1.month : 1.month
    current_month = gross_revenue(time)
    previous_month = gross_revenue(previous_time)
    difference = current_month - previous_month

    previous_month > 0 ? difference / previous_month * 100 : 0
  end

  def self.revenue_growth_rate_average
    arr = [revenue_growth_rate(1.month), revenue_growth_rate(2.month), revenue_growth_rate(3.month)]
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end

  def self.customer_growth_rate(time = false)
    previous_time = time ? time + 1.month : 1.month

    if active_accounts(time).present? and active_accounts(previous_time).present?
      current_month = active_accounts(time)
      previous_month = active_accounts(previous_time)
      difference = current_month - previous_month

      previous_month.to_f > 0 ? difference.to_f / previous_month.to_f * 100 : 0
    else
      0
    end
  end

  def self.customer_growth_rate_average
    arr = [customer_growth_rate(1.month), customer_growth_rate(2.month), customer_growth_rate(3.month)]
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end

  def self.arpu_growth_rate(time = false)
    previous_time = time ? time + 1.month : 1.month
    current_month = arpu(time)
    previous_month = arpu(previous_time)
    difference = current_month - previous_month

    previous_month.to_f > 0 ? difference.to_f / previous_month.to_f * 100 : 0
  end

  def self.arpu_growth_rate_average
    arr = [arpu_growth_rate(1.month), arpu_growth_rate(2.month), arpu_growth_rate(3.month)]
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end

  def self.downgraded_accounts(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_key: 'accounts.downgraded', occurred_on: range).pluck(:data).collect{|s| s.to_i}

    arr.size > 0 ? arr.inject{ |sum, el| sum + el } : 0
  end

  def self.upgraded_accounts(time = false)
    if time.kind_of?(Range)
      range = time
    elsif time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_key: 'accounts.upgraded', occurred_on: range).pluck(:data).collect{|s| s.to_i}

    arr.size > 0 ? arr.inject{ |sum, el| sum + el } : 0
  end

  def self.upgraded_accounts_total
    arr = self.where(method_key: 'accounts.upgraded').pluck(:data).collect{|s| s.to_i}
    if arr.present?
      arr.inject{ |sum, el| sum + el }
    else
      0
    end
  end

  def self.downgraded_accounts_total
    arr = self.where(method_key: 'accounts.downgraded').pluck(:data).collect{|s| s.to_i}
    if arr.present?
      arr.inject{ |sum, el| sum + el }
    else
      0
    end
  end

  def self.lost_rev(time = false)
    if time
      range = time.ago.beginning_of_month.to_date..time.ago.end_of_month.to_date
    else
      range = Date.today.beginning_of_month..Date.today
    end

    arr = self.where(method_name: 'balance.lost_rev', occurred_on: range).pluck(:data).collect{|s| s.to_i}
    (arr.inject{ |sum, el| sum + el }).to_f / 100
  end

  def self.lost_rev_total
    arr = self.where(method_name: 'balance.lost_rev').pluck(:data).collect{|s| s.to_i}
    if arr.present?
      (arr.inject{ |sum, el| sum + el }).to_f / 100
    else
      0
    end
  end

  def self.projection(primary, increase, months_out = 1)
    increase = increase / 100 + 1
    primary * increase ** months_out
  end

end