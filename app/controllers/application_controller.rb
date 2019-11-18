class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login, except: [:not_authenticated]

  helper_method :current_account

  if Rails.env == 'development'# and param[:set_user] == true
    before_filter :set_user

    def set_user
      user = User.find(91)
      auto_login(user)
    end
  end

protected
   def not_authenticated
      redirect_to login_path, alert: "Please login first."
   end

   def require_logout
      redirect_to dashboard_path if logged_in?
   end

   def require_admin
      redirect_to dashboard_path unless current_user and current_user.admin?
   end

   def current_account
     @current_account = current_user.account if current_user
   end
end
