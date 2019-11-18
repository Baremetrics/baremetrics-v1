class StatsController < ApplicationController

  def index
    if current_user.account.stripe_access_token
      @plans = current_user.account.stats.where(method_name: 'plan_details')
    end
  end
end
