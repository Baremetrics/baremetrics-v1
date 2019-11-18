class AccountMailer < ActionMailer::Base
  default from: "Baremetrics <hello@baremetrics.io>"

  def reset_password_email(user)
    headers['X-MC-Tags'] = 'Password Reset'
    @user = user
    @url  = "https://baremetrics.io/password_resets/#{user.reset_password_token}/edit"
    mail(:to => @user.email,
         :subject => "[Baremetrics] Password reset request")
  end

  def reports_email(user)
    headers['X-MC-Tags'] = "Report: Weekly"
    @account = user.account
    @range = 7.days.ago..Date.yesterday

    mail(:to => user.email, :subject => "[Baremetrics] #{@account.company} Weekly Report: #{Time.now.strftime('%A %B %-e')}")
  end

  def user_created(user, generated_password)
    headers['X-MC-Tags'] = 'User Created'
    @user = user
    @url  = "https://baremetrics.io/login"
    @generated_password  = generated_password
    mail(:to => user.email,
         :subject => "Baremetrics Account Created")
  end
end
