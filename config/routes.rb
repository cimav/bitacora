Bitacora::Application.routes.draw do
  root :to => 'home#index'

  match '/my-requests' => 'service_requests#index'
  match '/service_requests/:id/sample_list' => 'service_requests#sample_list'
  match '/service_requests/live_search' => 'service_requests#live_search'
  resources :service_requests 
  match '/samples/:id/requested_services_list' => 'samples#requested_services_list'
  resources :samples do
    resources :requested_services
  end
  match '/laboratory_services/live_search' => 'laboratory_services#live_search'
  match '/laboratory_services/:id/for_sample/:sample_id' => 'laboratory_services#for_sample'
  resources :laboratory_services
  resources :requested_services

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
end
