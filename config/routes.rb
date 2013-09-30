require 'resque/server'
Bitacora::Application.routes.draw do
  root :to => 'home#index'

  mount Resque::Server.new, :at => "/resque"  

  match '/login' => 'login#index'

  match '/folders' => 'service_requests#index'

  match '/service_requests/:id/sample_list' => 'service_requests#sample_list'
  match '/service_requests/live_search' => 'service_requests#live_search'
  match '/service_requests/form/:request_type_id' => 'service_requests#form'
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
        get 'sup_auth_dialog'
        get 'owner_auth_dialog'

        get 'grand_total'
        
        post 'new_technician'
        post 'update_participation'
        post 'update_hours'
        get 'technicians_table'

        post 'new_equipment'
        post 'update_eq_hours'
        get 'equipment_table'

        post 'new_material'
        post 'update_mat_qty'
        get 'materials_table'
        
        post 'new_other'
        post 'update_other_price'
        get 'others_table'
      end
    end
  end
  match '/requested_services/delete_tech' => 'requested_services#delete_tech'
  match '/requested_services/delete_eq' => 'requested_services#delete_eq'
  match '/requested_services/delete_mat' => 'requested_services#delete_mat'
  match '/requested_services/delete_other' => 'requested_services#delete_other'




  match '/laboratory_services/live_search' => 'laboratory_services#live_search'
  match '/laboratory_services/add_service_dialog' => 'laboratory_services#add_service_dialog'
  match '/laboratory_services/:id/for_sample/:sample_id' => 'laboratory_services#for_sample'
  resources :laboratory_services do
    member do
      get 'edit'
      get 'edit_cost'

      get 'grand_total'

      post 'new_technician'
      post 'update_participation'
      post 'update_hours'
      get 'technicians_table'

      post 'new_equipment'
      post 'update_eq_hours'
      get 'equipment_table'

      post 'new_material'
      post 'update_mat_qty'
      get 'materials_table'
        
      post 'new_other'
      post 'update_other_price'
      get 'others_table'
    end
  end
  resources :laboratory_members do
    member do
      get 'edit'
    end
  end
  resources :requested_services

  match '/users/live_search' => 'users#live_search'
  resources :users

  match '/laboratories/live_search' => 'laboratories#live_search'
  resources :laboratories

  resources :laboratory do
    member do
      get 'show' 

      get 'live_search'
      get 'admin'
      
      get 'admin_services'
      get 'admin_lab_services_live_search'
      get 'services_catalog'
      get 'new_service'

      get 'admin_members'
      get 'admin_lab_members_live_search'
      get 'new_member'

      get 'admin_equipment'
      get 'admin_lab_equipment_live_search'
      get 'new_equipment'
    end
  end

  resources :activity_log, :as => :activity_logs

  match '/service_files/ui/:service_request_id' => 'service_files#ui'
  match '/service_files/ui/:service_request_id/:sample_id' => 'service_files#ui'
  match '/service_files/ui/:service_request_id/:sample_id/:requested_service_id' => 'service_files#ui'
  match '/service_files/zip/:sample_id' => 'service_files#download_zip'
  match '/service_files/generate_zip/:sample_id' => 'service_files#generate_zip'
  match '/service_files/zip_ready/:sample_id' => 'service_files#zip_ready'
  resources :service_files do
    member do
      get 'file'
    end
  end

  match '/equipment/live_search' => 'equipment#live_search'
  resources :equipment

  match '/materials/live_search' => 'materials#live_search'
  match '/materials/new_dialog' => 'materials#new_dialog'
  resources :materials

  match '/clients/typeahead' => 'clients#typeahead'
  match '/clients/info' => 'clients#info'
  match '/clients/new_dialog' => 'clients#new_dialog'
  match '/clients/live_search' => 'clients#live_search'
  resources :clients

  match '/client_contacts/combo/:client_id' => 'client_contacts#combo'
  match '/client_contacts/new_dialog/:client_id' => 'client_contacts#new_dialog'
  resources :client_contacts

  match '/request_types/live_search' => 'request_types#live_search'
  resources :request_types

  match '/service_types/live_search' => 'service_types#live_search'
  resources :service_types

  match '/other_types/live_search' => 'other_types#live_search'
  resources :other_types

  match '/admin' => 'admin#index'
  match '/admin/clients' => 'admin#clients'
  match '/admin/client_types' => 'admin#client_types'
  match '/admin/equipment' => 'admin#equipment'
  match '/admin/materials' => 'admin#materials'
  match '/admin/laboratories' => 'admin#laboratories'
  match '/admin/users' => 'admin#users'
  match '/admin/request_types' => 'admin#request_types'
  match '/admin/service_types' => 'admin#service_types'
  match '/admin/other_types' => 'admin#other_types'


  match '/reports' => 'reports#index'
  match '/reports/eficiencia' => 'reports#eficiencia'

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'
  match "/logout" => 'sessions#destroy'

  match ':number' => 'home#redirect_requested_service', :constraints => { :number => /[^\/]*/ }

end
