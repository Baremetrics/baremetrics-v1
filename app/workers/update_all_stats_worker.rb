class UpdateAllStatsWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fast

  def perform
    Account.active.each do |account|
      account.update_all_stats
    end
  end
end
