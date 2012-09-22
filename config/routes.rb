Bitacora::Application.routes.draw do
  root :to => 'home#index'
  match '/login' => 'login#index'

  match '/my-requests' => 'service_requests#index'
  match '/service_requests/:id/sample_list' => 'service_requests#sample_list'
  match '/service_requests/live_search' => 'service_requests#live_search'
  resources :service_requests 
  match '/samples/:id/requested_services_list' => 'samples#requested_services_list'
  match '/samples/new_dialog/:service_request_id' => 'samples#new_dialog'
  resources :samples do
    resources :requested_services do
      member do
        get 'initial_dialog'
        get 'receive_dialog'
        get 'assign_dialog'
        get 'suspend_dialog'
        get 'reinit_dialog'
        get 'start_dialog'
        get 'finish_dialog'
        get 'cancel_dialog'
      end
    end
  end


  match '/laboratory_services/live_search' => 'laboratory_services#live_search'
  match '/laboratory_services/:id/for_sample/:sample_id' => 'laboratory_services#for_sample'
  resources :laboratory_services do
    member do
      get 'edit'
    end
  end
  resources :laboratory_members do
    member do
      get 'edit'
    end
  end
  resources :requested_services
  resources :laboratory do
    member do
      get 'live_search'
      get 'admin'
      get 'admin_services'
      get 'admin_lab_services_live_search'
      get 'new_service'
      get 'admin_members'
      get 'admin_lab_members_live_search'
      get 'new_member'
    end
  end

  resources :activity_log, :as => :activity_logs

  match '/service_files/ui/:service_request_id' => 'service_files#ui'
  match '/service_files/ui/:service_request_id/:sample_id' => 'service_files#ui'
  match '/service_files/ui/:service_request_id/:sample_id/:requested_service_id' => 'service_files#ui'
  resources :service_files do
    member do
      get 'file'
    end
  end

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'
end
