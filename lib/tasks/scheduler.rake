desc "This task is called by the Heroku scheduler add-on"

task :update_all_stats => :environment do
  UpdateAllStatsWorker.perform_async
end