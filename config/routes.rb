Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post "slack_commands", to: "slack_commands#create"
  post "interactions", to: "interactions#create"
end
