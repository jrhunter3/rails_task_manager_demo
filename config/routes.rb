Rails.application.routes.draw do
  devise_for :users

  resources :projects do
    resources :tasks do
      member do
        post :transition
      end
      resources :comments, only: %i[create edit update destroy]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :projects do
        resources :tasks
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "projects#index"
end
