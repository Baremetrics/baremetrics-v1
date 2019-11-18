class SessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  before_filter :require_logout, only: [:new]

  def new
    @user = User.new
  end

  def create
    #account_check = User.find_by_email(params[:email])

    # if account_check and account_check.cancelled?
    #   flash.now.alert = "You cancelled your account. If you'd like to re-activate it, please email support@baremetrics.io"
    #   render :new
    # else
      @user = login(params[:email], params[:password], remember_me = true)
      Rails.logger.warn(@user)
      if @user
        redirect_to dashboard_path
      else
        flash.now.alert = "Email or password was invalid"
        render :new
      end
    # end
  end

  def destroy
    logout
    redirect_to root_url, notice: "Logged out!"
  end
end
