Streamphish::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => "/admin", :as => "rails_admin"
  mount Resque::Server, :at => "/resque"

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
  resources :tours
  
  get "/download/:id"   => "albums#download"
  get "/years"          => "pages#years"
  get "/venues"         => "pages#venues"
  get "/cities"         => "pages#cities"
  get "/states"         => "pages#states"
  get "/countries"      => "pages#countries"
  
  # ROOT
  root :to => "pages#index"

end