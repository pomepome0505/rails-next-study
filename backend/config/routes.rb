Rails.application.routes.draw do
  namespace :api do
    get "health", to: "health#show"

    resource :session, only: %i[create destroy]
    post "password_resets",        to: "password_resets#create"
    put  "password_resets/:token", to: "password_resets#update", as: :password_reset

    get "me", to: "users#show"

    resources :tasks
  end
end
