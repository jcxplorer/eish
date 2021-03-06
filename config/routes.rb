ActionController::Routing::Routes.draw do |map|  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  map.connect "events/past", :controller => "events", :action => "past"
  map.connect "events/past.:format", :controller => "events", :action => "past"

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.admin "admin", :namespace => "admin", :controller => "home"
  map.password_reset "users/:username/reset/:reset_hash", :controller => "users", :action => "password_reset"
  map.login "login", :controller => "sessions", :action => "new"
  map.logout "logout", :controller => "sessions", :action => "destroy"
  map.request_credentials "request_credentials", :controller => "users", :action => "request_credentials"
  map.article_diff "admin/articles/:id/compare/:rev_a/:rev_b", :namespace => "admin", :controller => "articles", :action => "compare"
  map.change_revision "admin/articles/:id/change_revision/:revision", :namespace => "admin", :controller => "articles", :action => "change_revision"
  map.categories "articles/categories/:id", :controller => "articles", :action => "categories"
  map.news_with_page "news/page/:page", :controller => "news", :action => "index"
  map.articles_with_page "articles/page/:page", :controller => "articles", :action => "index"
  map.categories_with_page "articles/categories/:id/page/:page", :controller => "articles", :action => "categories"
  map.account_activation "users/:username/activate/:activation_hash", :controller => "users", :action => "activate"
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  
  map.resources :news
  map.resources :articles
  map.resources :events
  map.resources :galleries
  map.resources :users, :member => { :remove => :get }
  map.resources :profiles

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  map.namespace :admin do |admin|
    admin.resources :users
    admin.resources :news, :collection => { :bulk_action => :post }
    admin.resources :articles, :collection => { :bulk_action => :post }
    admin.resources :events, :collection => { :bulk_action => :post }
    admin.resources :galleries, :collection => { :bulk_action => :post }
    admin.resources :categories
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect 'sitemap.:format', :controller => "sitemap", :action => "index"
  map.connect "search/opensearch.xml", :controller => "search", :action => "opensearch"
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
