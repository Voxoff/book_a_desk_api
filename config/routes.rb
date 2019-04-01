Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :bookings
      resources :tables
      post '/login', to: 'auth#create'
      get '/profile', to: 'users#profile'
    end
  end

  # get 'users/auth/github/callback', to: redirect  { |params, request| "/auth/github/callback?#{request.params.to_query}" }
end
