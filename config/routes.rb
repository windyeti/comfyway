Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: "registrations"}
  root to: "visitors#index"

  resources :products do
    collection do
      get :create_csv_with_params
    end
  end
end
