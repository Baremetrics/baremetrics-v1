class ReportsWorker
  include Sidekiq::Worker

  def perform
    User.where(reports_weekly: true).each do |user|
      AccountMailer.reports_email(user).deliver if user.account.plan.feature_email_reports == true
    end
  end
end