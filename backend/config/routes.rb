Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  post '/auth/login', to: 'authentication#login'
  
  resources :users, only: [:create, :index]
  get '/users/me', to: 'users#me'

  resources :organizations, only: [:index, :create] do
    resources :tasks
    resources :statistics, only: [:index]
    get :users, on: :member
  end
end
