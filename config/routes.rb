Bitacora::Application.routes.draw do
  root :to => 'home#index'

  match '/my-requests' => 'service_requests#index'
  match '/new-request' => 'service_requests#new_request'
  resources :service_requests

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
end
