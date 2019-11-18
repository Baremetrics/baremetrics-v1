class UsersController < ApplicationController
  before_filter :find_user, :only => [:edit, :destroy, :update]
  before_filter :verify_ownership, :only => [:edit, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.account = current_account
    generated_password = User.generate_temporary_password
    @user.password = generated_password
    @user.change_password = true

    if @user.save
      AccountMailer.user_created(@user, generated_password).deliver
      redirect_to settings_path, notice: 'User added and emailed login details'
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])

      if params[:user][:change_password] == 't'
        @user.update_attribute(:change_password, false)
        redirect_to settings_path
      else
        redirect_to settings_path, notice: 'User updated!'
      end
    else
      render :action => :edit
    end
  end

private
  def find_user
    @user = User.find(params[:id])
    redirect_to(settings_path) if !@user
  end

  def verify_ownership
    redirect_to(settings_path) unless @user.account == current_account or current_account.admin.present?
  end
end
