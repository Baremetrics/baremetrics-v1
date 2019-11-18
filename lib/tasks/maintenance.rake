namespace :maintenance do
   desc "Reprocess all accounts"
   task :reprocess => :environment do
      Account.all.each do |account|
         account.process_all_stats
      end
   end
end