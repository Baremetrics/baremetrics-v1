class SubscriptionUpdateItemWorker
  include Sidekiq::Worker

  def perform(account_id, date)
    date = date.to_date
    account = Account.find(account_id)
    api_key = account.stripe_access_token

    # Destroy previous bits so we don't get double entries -- Needed if worker restart mid-process
    Stat.where(account_id: account.id, method_name: 'accounts.created', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_name: 'accounts.cancelled', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_key: 'accounts.downgraded', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_key: 'accounts.upgraded', occurred_on: date).destroy_all

    offset = 0
    data_count = false
    until data_count == 0
      subscriptions = Stripe::Event.all(
        {type: 'customer.subscription.*',
        count: 100,
        offset: offset,
        created: {
          gte: date.beginning_of_day.to_i,
          lte: date.end_of_day.to_i
        }},
        api_key
      )
      offset += 100
      data_count = subscriptions.data.count

      if data_count > 0
        subscription_listings = subscriptions.data
        upgrade_count, downgrade_count, deleted_count, created_count = 0, 0, 0, 0

        subscription_listings.each do |subscription|
          subscription_type = subscription.type

          if subscription_type == 'customer.subscription.created' and subscription.data.object.plan.present?
            if subscription.data.object.plan.amount > 0
              created_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'accounts.created', "accounts.#{subscription.data.object.plan.id}.created", date)
              new_created_stat_count = created_stat.data.to_i + 1
              created_stat.update_attributes(data: new_created_stat_count)
            end
          elsif subscription_type == 'customer.subscription.updated' and subscription.data.object.plan.present? and subscription.data.previous_attributes.present? and JSON.parse(subscription.data.previous_attributes.to_s)['plan'].present?
            # If new plan is cheaper than old plan, count as downgrade
            if subscription.data.object.plan.amount < subscription.data.previous_attributes.plan.amount
              downgrade_count += 1
            end

            # If new plan is more expensive than old plan, count as upgrade
            if subscription.data.object.plan.amount > subscription.data.previous_attributes.plan.amount
              upgrade_count += 1
            end

            # If the new plan is free, then consider them 'cancelled'
            if subscription.data.object.plan.amount == 0 and subscription.data.previous_attributes.plan.amount > 0
              cancelled_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'accounts.cancelled', "accounts.#{subscription.data.previous_attributes.plan.id}.cancelled", date)
              new_cancelled_stat_count = cancelled_stat.data.to_i + 1
              cancelled_stat.update_attributes(data: new_cancelled_stat_count)
            end

          elsif subscription_type == 'customer.subscription.deleted' and subscription.data.object.plan.present?
            # Only add to deleted if they cancelled from paying plan
            if subscription.data.object.plan.amount > 0
              plan_id = subscription.data.object.plan.id
              cancelled_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'accounts.cancelled', "accounts.#{plan_id}.cancelled", date)
              new_cancelled_stat_count = cancelled_stat.data.to_i + 1
              cancelled_stat.update_attributes(data: new_cancelled_stat_count)
            end
          end
        end

        # Number of downgrades
        if downgrade_count > 0
          downgrade_stats = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'event', "accounts.downgraded", date)
          new_downgrade_stats = downgrade_stats.data.to_i + downgrade_count
          downgrade_stats.update_attributes(data: new_downgrade_stats)
        end

        # Number of upgrades
        if upgrade_count > 0
          upgrade_stats = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'event', "accounts.upgraded", date)
          new_upgrade_stats = upgrade_stats.data.to_i + upgrade_count
          upgrade_stats.update_attributes(data: new_upgrade_stats)
        end


      end
    end


  end
end