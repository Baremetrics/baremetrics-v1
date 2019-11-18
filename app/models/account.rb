class Account < ActiveRecord::Base
  has_many :stats
  has_many :events
  has_many :users
  belongs_to :plan

  attr_accessible :company, :phone, :stripe_access_token, :stripe_livemode, :stripe_publishable_key, :stripe_account_id, :stripe_connected_at, :users_attributes, :last_synced, :stripe_token, :plan_id, :stripe_customer_id, :active

  attr_accessor :stripe_token

  accepts_nested_attributes_for :users

  scope :active, where(active: true)

  before_save :update_stripe

  def update_stripe
    return if Rails.env.development?
    if stripe_customer_id.nil?
      if !stripe_token.present? and plan.price > 0
        raise "Stripe token not present. Can't create account."
      end
      if plan.price == 0
        customer = Stripe::Customer.create(
          :email => users.first.email,
          :description => users.first.name,
          :plan => plan.api_handle
        )
      else
        customer = Stripe::Customer.create(
          :email => users.first.email,
          :description => users.first.name,
          :card => stripe_token,
          :plan => plan.api_handle
        )
      end
    else
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = users.first.email
      customer.description = users.first.name
      customer.save
    end

    self.last_4_digits = customer.cards.data.first.last4 if plan.price > 0

    self.stripe_customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end

  def connected?
    stripe_access_token.present?
  end

  def process_all_stats
    queue_name = choose_queue

    Sidekiq::Client.push('class' => PlanWorker, 'args' => [id], 'queue' => queue_name)
    Sidekiq::Client.push('class' => ChargesWorker, 'args' => [id, false, queue_name], 'queue' => queue_name)
    Sidekiq::Client.push('class' => SubscriptionUpdateWorker, 'args' => [id, false, queue_name], 'queue' => queue_name)
    update_attributes(last_synced: Date.yesterday.end_of_day)
  end

  def last_stat
    order(:created_at).pluck(:created_at).last
  end

  def update_all_stats
    queue_name = choose_queue

    Sidekiq::Client.push('class' => PlanWorker, 'args' => [id], 'queue' => queue_name)
    Sidekiq::Client.push('class' => ChargesWorker, 'args' => [id, true, queue_name], 'queue' => queue_name)
    Sidekiq::Client.push('class' => SubscriptionUpdateWorker, 'args' => [id, true, queue_name], 'queue' => queue_name)
    update_attributes(last_synced: Date.yesterday.end_of_day)
  end

  def destroy_all_stats
    queue_name = choose_queue

    Sidekiq::Client.push('class' => DestroyStatsWorker, 'args' => [id], 'queue' => queue_name)
  end

  def send_reports
    queue_name = choose_queue

    Sidekiq::Client.push('class' => ReportsWorker, 'queue' => queue_name)
  end

  def admin_user
    users.where(admin: true).first
  end

  def importing?
    (stats.count < 75) or (Time.now - stats.order(:created_at).pluck(:created_at).last < 60)
  end

  def choose_queue
    queues = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]

    queues.each_with_index do |queue, index|
      if Sidekiq::Queue.new(queue).size == 0
        break queue
      elsif index == 25
        queues.sample
      end
    end
  end
end
