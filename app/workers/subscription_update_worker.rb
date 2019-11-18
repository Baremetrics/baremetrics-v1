class SubscriptionUpdateWorker
  include Sidekiq::Worker

  def perform(account_id, update = false, queue_name)
    account = Account.find(account_id)
    api_key = account.stripe_access_token

    if update == true
      total_charges = Stripe::Charge.all({created: { gte: 7.days.ago.to_i }}, api_key).count

      if Stripe::Charge.all({created: { gte: 7.days.ago.to_i }, offset: total_charges-1, count:1}, api_key).first.present?
        start_date = Time.at(Stripe::Charge.all({created: { gte: 7.days.ago.to_i }, offset: total_charges-1, count:1}, api_key).first.created).to_datetime.to_date
      else
        start_date = Time.at(7.days.ago.to_i).to_datetime.to_date
      end

      end_date = Date.yesterday.to_date
    else
      total_charges_ever = Stripe::Charge.all({}, api_key).count
      start_date = Time.at(Stripe::Charge.all({offset: total_charges_ever-1, count:1}, api_key).first.created).to_datetime.to_date
      end_date = Date.yesterday.to_date
    end

    (start_date..end_date).each do |date|
      Sidekiq::Client.push('class' => SubscriptionUpdateItemWorker, 'args' => [account_id, date], 'queue' => queue_name)
    end
  end
end