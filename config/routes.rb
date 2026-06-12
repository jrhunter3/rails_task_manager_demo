Rails.application.routes.draw do
  devise_for :users

  resources :projects

  get "up" => "rails/health#show", as: :rails_health_check

  root "projects#index"
end
