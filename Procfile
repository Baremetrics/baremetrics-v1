web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: env DB_POOL=100 bundle exec sidekiq -e production -C config/sidekiq.yml
clock: bundle exec clockwork lib/clock.rb