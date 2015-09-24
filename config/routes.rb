Rails.application.routes.draw do

  resources :registrations do
  	get :course_id, to: "registrations#new" #-> yoururl.com/registrations/:course_id
  end

  resources :courses

  root "courses#index"

  post "registrations/hook"
  
end
