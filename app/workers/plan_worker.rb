class PlanWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)
    api_key = account.stripe_access_token

    Stat.where(account_id: account_id, method_name: 'plan').destroy_all
    Stat.where(account_id: account_id, method_name: 'plan_details').destroy_all

    Stripe::Plan.all({count: 100}, api_key).each do |plan|
      # Create plans
      Stat.find_or_create_by_account_id_and_method_name_and_method_key(account_id, 'plan_details', "plan.#{plan.id}") do |r|
        r.data = plan.to_json
      end

      begin
        # Update # of customers
        customer_count = Stripe::Customer.all({'subscription[plan]' => plan.id}, api_key).count
        stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'plan', "plan.#{plan.id}.customers", Time.now)
        stat.update_attributes(data: customer_count)
      rescue Stripe::InvalidRequestError => e
        raise if e.message =~ /Rate/
      end
    end
  end
end
