Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: "registrations"}
  root to: "visitors#index"

  resources :products do
    collection do
      get :create_csv_with_params
      post :import_ledron
      post :price_edit
      post :price_update
    end
  end
end
