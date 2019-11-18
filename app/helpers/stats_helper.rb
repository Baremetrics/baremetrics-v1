module StatsHelper
  def account_stats_count
    current_account.stats.count
  end
end
