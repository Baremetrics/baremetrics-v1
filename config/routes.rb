Baremetrics::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  match 'login' => 'sessions#new'
  match 'logout' => 'sessions#destroy'
  match 'signup' => 'accounts#new'
  match 'settings' => 'accounts#edit'
  match 'dashboard' => 'stats#index'
  match 'pricing' => 'pages#pricing'
  match 'home' => 'pages#index'
  match 'demo' => 'pages#demo'
  match 'security' => 'pages#security'
  match 'privacy' => 'pages#privacy'
  match 'terms' => 'pages#terms'
  match 'reset_password/:id' => 'password_resets#edit'

  resources :stats, :sessions, :password_resets, :users

  resources :accounts do
    collection do
      get 'connected'
      delete 'disconnect'
    end
  end

  root :to => 'pages#index'
end
