Rails.application.routes.draw do
  resources :users do
    resources :pets
  end

  resources :pets, only: [] do
    resources :health_records
    resources :medications
    resources :reminders do
      member do
        post :complete
      end
    end
  end

  resources :vet_offices
  resources :veterinarians do
    resources :ratings, only: [:create, :update]
  end

  root "users#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
