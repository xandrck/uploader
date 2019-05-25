Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'statistics#index'

  resources :statistics
  post 'statistic_upload', to: 'statistics#upload'
end
