Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations, :sessions]

  # Receive communication from bots (Admin Client App)
  resources :kitties, only: [:create], constraints: { format: 'json' }, controller: 'api/v1/bots/register'
  post 'dogs', to: 'api/v1/bots/command_control#routing'

  # Receive communication from Api Client Gateway
  post 'frogs', to: 'api/v1/client_gateways/receiver#index'



  # Management
  post 'login', constraints: { format: 'json' }, to: 'api/v1/management/session#login'
  get 'logout', constraints: { format: 'json' }, to: 'api/v1/management/session#logout'

  scope :client, only: [], constraints: { format: 'json' } do
    get '', to: 'api/v1/management/clients#index'
    post 'deploy', to: 'api/v1/management/clients#deploy_instance'
    post 'shut', to: 'api/v1/management/clients#shut_instance'
  end

  scope :bots, only: [] do
    get '', to: 'api/v1/management/bots#index'
    get 'commands', to: 'api/v1/management/bots#commands'
    get ':code', to: 'api/v1/management/bots#show'
    post 'execute', to: 'api/v1/management/bots#execute'
  end

  # Facade Access
  get 'articles', constraints: { format: 'json' }, to: 'api/v1/facade/content#index'
  scope :app, only: [] do
    get 'admin', to: 'api/v1/facade/content#admin'
    get 'admin_dependency', to: 'api/v1/facade/content#admin_dependency'

    get 'client', to: 'api/v1/facade/content#client'
    get 'client_dependency', to: 'api/v1/facade/content#client_dependency'
  end


  # Default
  match '/', to: ->(env) { [503, {}, ['']] }, via: :all
  match '/rails/action_mailbox/*path', to: ->(env) { [503, {}, ['']] }, via: :all
  match '/rails/conductor/action_mailbox/*path', to: ->(env) { [503, {}, ['']] }, via: :all
  match '*path', to: ->(env) { [503, {}, ['']] }, via: :all
end
