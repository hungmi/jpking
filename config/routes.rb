Rails.application.routes.draw do
  root "pages#home"
  resources :categories, except: [:index]
  controller 'pages' do
    get 'guide'
    get 'cart'
    get 'register'
    get 'fb_bot'
    post 'crawl_posts'
    get 'scanner'
  end
  resources :products, except: [:show]
  resources :order_items
  resources :orders do
    member do
      get "pay"
      get "cancel"
      get "reorder"
    end
    collection do
      post "merge"
    end
  end
  resources :links
  resources :cart_items
  # resources :carts
  controller 'sessions' do
    get '/login' => :new, as: :login
    post '/sign_in' => :create, as: :sign_in
    delete '/logout' => :destroy, as: :logout
    post '/row_count' => :row_count, as: :row_count
  end
  resources :users
  resources :shops
  namespace :admin do
    controller 'orders' do
      get "orders" => :index
      post "importing"
      post "imported"
      post "unavailable"
    end
    get "fb_bot"
    post "post_to_orders"
    post "add_to_etoile_cart"
  end

  get "/:item_code/:product_name" => "products#show", as: :human_product
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
