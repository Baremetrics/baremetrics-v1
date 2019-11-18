# config/unicorn.rb
rails_env = ENV['RAILS_ENV'] || 'production'

#worker_processes (rails_env == 'production' ? ENV["WEB_CONCURRENCY"] || 10 : 1)
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

timeout 60
preload_app true


before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  if defined?(ActiveRecord::Base)
    #config = Rails.application.config.database_configuration[Rails.env]
    #config['pool'] = ENV['DB_POOL'] || 5
    pool = ENV['DB_POOL'] || 100
    database_url = ENV['DATABASE_URL']
    if(database_url)
      ENV['DATABASE_URL'] = "#{database_url}?pool=#{pool}"
      ActiveRecord::Base.establish_connection
    end
  end
end