Rails.application.routes.draw do
  get 'insales/index'
  devise_for :users, controllers: {registrations: "registrations"}
  root to: "visitors#index"

  resources :products do
    collection do
      get :create_xls_with_params
      get :create_csv_update
      get :import_insales_xml
      post :import_ledron
      post :import_isonex
      post :price_edit
      post :price_update
      get :update_distributor
      post :deactivated_selected
      post :show_selected
    end
  end

  resources :insales do
    get :import_goods
    get :export_goods
  end

  mount ActionCable.server => '/cable'
end
