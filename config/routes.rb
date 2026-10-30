Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "tasks#index"
  resources :tasks do
    patch :transition, on: :member
  end
  post "demo/reset", to: "demo_sessions#reset", as: :reset_demo
end
