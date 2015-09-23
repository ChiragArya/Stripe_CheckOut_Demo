Rails.application.routes.draw do
  resources :registrations

  resources :courses

  root "courses#index"

  post "registrations/hook"
  
end
