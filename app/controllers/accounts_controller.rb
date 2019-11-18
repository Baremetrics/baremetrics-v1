class AccountsController < ApplicationController
  skip_before_filter :require_login, only: [:index, :new, :create]
  before_filter :require_logout, only: [:new, :create]
  before_filter :find_account, only: [:edit, :update]

  def new
    @account = Account.new
    @account.users.build

    @plan = Plan.find_by_permalink(params[:plan])

    redirect_to pricing_path if @plan.blank?
  end

  def create
    @account = Account.new(params[:account])

    if @account.save
      user = @account.users.first

      Analytics.track(
        user_id: current_user.id,
        event: 'Signed Up',
        properties: {
          plan_name: @account.plan.title
        }
      )

      auto_login(user, should_remember=true)
      redirect_to '/dashboard', flash: { signup_success: true }
    else
      @plan = Plan.find_by_id(params[:account][:plan_id])
      render action: "new"
    end
  end

  def edit
    @user = current_user
  end

  def update
    if @account.update_attributes(params[:account])
      redirect_to settings_path, notice: 'Your account was successfully updated.'
    else
      render action: "edit"
    end
  end

  def connected
    @account = current_user.account

    require "uri"
    require "net/http"

    request = {
      'client_secret' => ENV['STRIPE_SECRET_KEY'],
      'code' => params['code'],
      'grant_type' => 'authorization_code'
    }

    response = RestClient.post 'https://connect.stripe.com/oauth/token', request

    values = JSON.parse(response.body)

    @account.update_attributes(
      stripe_access_token: values['access_token'],
      stripe_livemode: values['livemode'],
      stripe_publishable_key: values['stripe_publishable_key'],
      stripe_account_id: values['stripe_user_id'],
      stripe_connected_at: Time.now
    )

    @account.process_all_stats

    redirect_to dashboard_path, notice: "Your Stripe account is now connected! Give us a few minutes to process all of your data."
  end

  def disconnect
    @account = current_user.account
    @account.update_attributes(
      stripe_access_token: nil,
      stripe_publishable_key: nil,
      stripe_account_id: nil,
      stripe_connected_at: nil
    )

    @account.destroy_all_stats

    redirect_to settings_path, notice: "Your Stripe account has been disconnected!"
  end

private
  def find_account
    @account = current_account
    redirect_to(root_path) if !@account
  end

end
