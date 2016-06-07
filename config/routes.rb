require 'resque/server'
Bitacora::Application.routes.draw do
  root :to => 'home#index'

  mount Resque::Server.new, :at => "/resque"  

  get '/login' => 'login#index'
  get '/set_user/:email' => 'login#set_user', :constraints => { :email => /[^\/]+/  }

  get '/folders' => 'service_requests#index'
  get '/folders/new' => 'service_requests#new'

  match '/service_requests/live_search' => 'service_requests#live_search', via: [:get, :post]
  get '/service_requests/edit_dialog/:id' => 'service_requests#edit_dialog'
  get '/service_requests/form/:request_type_id' => 'service_requests#form'
  get '/service_requests/:id/actions' => 'service_requests#actions'
  get '/service_requests/:id/quotation' => 'service_requests#quotation'
  post '/service_requests/:id/send_quote' => 'service_requests#send_quote'
  get '/service_requests/:id/view_report' => 'service_requests#view_report'
  get '/service_requests/:id/view_report_tipo_2' => 'service_requests#view_report_tipo_2'
  get '/service_requests/:id/add_collaborator_dialog' => 'service_requests#add_collaborator_dialog'
  post '/service_requests/:id/add_collaborator' => 'service_requests#add_collaborator'
  get '/service_requests/:id/get_collaborators' => 'service_requests#get_collaborators'
  post '/service_requests/:id/send_report' => 'service_requests#send_report'
  post '/service_requests/:id/send_report_tipo_2' => 'service_requests#send_report_tipo_2'
  post '/service_requests/delete_collaborator' => 'service_requests#delete_collaborator'
  get '/service_requests/:id/folder_without_services' => 'service_requests#folder_without_services'
  get '/service_requests/:id/files_list' => 'service_requests#files_list'
  get '/vinculacion_files/get/:id', to: 'vinculacion_files#file'


  resources :service_requests 
  get '/samples/:id/requested_services_list' => 'samples#requested_services_list'
  get '/samples/:id/lab_view_requested_services_list' => 'samples#lab_view_requested_services_list'
  get '/samples/new_dialog/:service_request_id' => 'samples#new_dialog'
  get '/samples/edit_dialog/:id' => 'samples#edit_dialog'
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
        get 'send_quote_dialog'
        get 'delete_dialog'

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

        get 'lab_view'
      end
    end
  end
  post '/requested_services/delete_tech' => 'requested_services#delete_tech'
  post '/requested_services/delete_eq' => 'requested_services#delete_eq'
  post '/requested_services/delete_mat' => 'requested_services#delete_mat'
  post '/requested_services/delete_other' => 'requested_services#delete_other'
  get  '/requested_services/:id' => 'requested_services#show'
  get  '/requested_services/:id/files_list' => 'requested_services#files_list'
  get  '/laboratory/:lab_id/s/:id' => 'requested_services#lab_view'




  get '/laboratory_services/live_search' => 'laboratory_services#live_search'
  get '/laboratory_services/add_service_dialog' => 'laboratory_services#add_service_dialog'
  get '/laboratory_services/:id/for_sample/:sample_id' => 'laboratory_services#for_sample'
  resources :laboratory_services do
    member do
      get 'status'
      get 'status_by_rs'
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

  get '/users/live_search' => 'users#live_search'
  resources :users

  get '/laboratories/live_search' => 'laboratories#live_search'
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
  get  '/laboratory/:id/f/*filter' => 'laboratory#show'

  resources :activity_log, :as => :activity_logs
  resources :alerts
  get '/alerts/laboratory_service/:id' => 'alerts#get_from_laboratory_service'
  get '/alerts/technician/:id' => 'alerts#get_from_technician'
  get '/alerts/equipment/:id' => 'alerts#get_from_equipment'
  post '/alerts/resolve/:id/:from/:from_id' => 'alerts#resolve'

  get '/service_files/ui/:service_request_id' => 'service_files#ui'
  get '/service_files/ui/:service_request_id/:sample_id' => 'service_files#ui'
  get '/service_files/ui/:service_request_id/:sample_id/:requested_service_id' => 'service_files#ui'
  get '/service_files/zip/:sample_id' => 'service_files#download_zip'
  get '/service_files/generate_zip/:sample_id' => 'service_files#generate_zip'
  get '/service_files/zip_ready/:sample_id' => 'service_files#zip_ready'
  resources :service_files do
    member do
      get 'file'
      get 'remove_file'
    end
  end

  get '/equipment/live_search' => 'equipment#live_search'
  resources :equipment

  get '/materials/live_search' => 'materials#live_search'
  get '/materials/new_dialog' => 'materials#new_dialog'
  resources :materials

  get '/clients/typeahead' => 'clients#typeahead'
  get '/clients/info' => 'clients#info'
  get '/clients/new_dialog' => 'clients#new_dialog'
  get '/clients/live_search' => 'clients#live_search'
  resources :clients

  get '/client_contacts/combo/:client_id' => 'client_contacts#combo'
  get '/client_contacts/new_dialog/:client_id' => 'client_contacts#new_dialog'
  resources :client_contacts

  get '/request_types/live_search' => 'request_types#live_search'
  resources :request_types

  get '/service_types/live_search' => 'service_types#live_search'
  resources :service_types

  get '/other_types/live_search' => 'other_types#live_search'
  resources :other_types


  get '/admin' => 'admin#index'
  get '/admin/clients' => 'admin#clients'
  get '/admin/client_types' => 'admin#client_types'
  get '/admin/equipment' => 'admin#equipment'
  get '/admin/materials' => 'admin#materials'
  get '/admin/laboratories' => 'admin#laboratories'
  get '/admin/users' => 'admin#users'
  get '/admin/request_types' => 'admin#request_types'
  get '/admin/service_types' => 'admin#service_types'
  get '/admin/other_types' => 'admin#other_types'


  get '/reports' => 'reports#index'
  get '/reports/eficiencia' => 'reports#eficiencia'

  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  get "/logout" => 'sessions#destroy'

  get '/go-folder/:number' => 'home#redirect_service_request', :constraints => {:number => /.*/} 
  get ':number' => 'home#redirect_requested_service', :constraints => {:number => /.*/} 

end
