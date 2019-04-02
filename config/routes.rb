Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      resources :bookings
      post '/login', to: 'auth#create'
      get '/profile', to: 'users#profile'
      post 'auth/github/callback', to: 'users#omniauth'
      post '/tables', to: 'tables#index'
    end
  end

  # get 'users/auth/github/callback', to: redirect  { |params, request| "/auth/github/callback?#{request.params.to_query}" }
end
