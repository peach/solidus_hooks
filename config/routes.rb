Spree::Core::Engine.routes.append do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :events
      resources :web_hooks
    end
  end
end
