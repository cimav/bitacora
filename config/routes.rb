Bitacora::Application.routes.draw do
  root :to => 'home#index'

  match '/my-requests' => 'service_requests#index'
  match '/service_requests/:id/sample_list' => 'service_requests#sample_list'
  resources :service_requests

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
end
