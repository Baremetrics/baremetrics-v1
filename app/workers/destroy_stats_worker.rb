class DestroyStatsWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)

    account.stats.destroy_all
  end
end
