Streamphish::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :shows do
    member do
      get "request_download", :as => "request_download"
    end
  end
  resources :songs
  resources :tracks do
    member do
      get "download"
    end
  end
  
  get "/download/:id" => "albums#download"
  get "/test/" => "sandboxes#test"

  get "/years" => "pages#years"
  get "/venues" => "pages#venues"
  get "/tours" => "pages#tours"
  get "/cities" => "pages#cities"
  get "/states" => "pages#states"
  get "/countries" => "pages#countries"
  
  root :to => "pages#index"

end
