Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations, :sessions]
  post 'login', to: 'api/v1/sessions#login'
  get 'logout', to: 'api/v1/sessions#logout'

  post C_C_POOL, to: 'webhooks/receiver#index'

  post CLIENT_C_POOL, to: 'api/v1/client_control#routing'

  resources :bots, only: [], constraints: { format: 'json' } do
    collection do
      get '', to: 'api/v1/bots#index'
      get ':code', to: 'api/v1/bots#show'
    end
  end

  resources :commands, only: [], constraints: { format: 'json' } do
    collection do
      get '', to: 'api/v1/bots#commands'
      post 'execute', to: 'api/v1/bots#execute'
    end
  end

  match '/', to: ->(env) { [503, {}, ['']] }, via: :all
  match '/rails/action_mailbox/*path', to: ->(env) { [503, {}, ['']] }, via: :all
  match '/rails/conductor/action_mailbox/*path', to: ->(env) { [503, {}, ['']] }, via: :all
  match '*path', to: ->(env) { [503, {}, ['']] }, via: :all
end
