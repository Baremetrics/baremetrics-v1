require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require 'clockwork'
include Clockwork

every(1.day, 'Update all stats', :at => '03:00') { UpdateAllStatsWorker.perform_async }
every(1.week, 'Send out weekly reports', :at => 'Monday 14:00') { ReportsWorker.perform_async }