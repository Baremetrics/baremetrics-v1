class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  before_filter :require_logout

  def create
    @user = User.find_by_email(params[:email])

    if @user
      @user.deliver_reset_password_instructions! if @user

      redirect_to(login_path, notice: 'Instructions have been sent to your email.')
    else
      flash[:alert] = "We couldn't find an account with that email address"
      render 'new'
    end
  end

  def new
   @title = "Reset Your Password"
  end

  def edit
   @title = "Reset Your Password"
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated unless @user
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)
    not_authenticated unless @user
    if @user.change_password!(params[:user][:password])
      @user = login(@user.email, params[:user][:password])

      redirect_to(dashboard_path, notice: 'Password was successfully updated.')
    else
      render action: "edit"
    end
  end
end