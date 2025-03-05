Rails.application.routes.draw do
  get 'portal/:id', to: 'portal#index', as: 'portal'
  root 'portal#index'

  get 'pet_app', to: 'portal#pet_app'
  get 'pet_app_dependency', to: 'portal#pet_app_dependency'

  get 'groceries_app', to: 'portal#groceries_app'
  get 'groceries_app_dependency', to: 'portal#groceries_app_dependency'


  # Default
  match '/rails/action_mailbox/*path', to: ->(env) { [503, {}, ['']] }, via: :all
  match '/rails/conductor/action_mailbox/*path', to: ->(env) { [503, {}, ['']] }, via: :all
  match '*path', to: ->(env) { [503, {}, ['']] }, via: :all
end
