Bitacora::Application.routes.draw do
  root :to => redirect('/requests')
  match '/requests' => 'requests#index'
  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
end
