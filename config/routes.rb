RUBYGEM_NAME_MATCHER = /[A-Za-z0-9\-\_\.]+/

Gemcutter::Application.routes.draw do |map|

  ################################################################################
  # API v1

  namespace :api do
    namespace :v1 do
      resource :api_key, :only => :show do
        put :reset
      end

      resources :downloads, :only => :index

      resources :rubygems, :path => "gems", :only => [:create, :show] do
        collection do
          delete :yank
          put :unyank
        end
        resource :owners, :only => [:show, :create, :destroy]
      end

      resource :search, :only => :show

      resources :web_hooks, :only => [:create, :index] do
        collection do
          delete :remove
          post :fire
        end
      end
    end
  end

  ################################################################################
  # API v0

  scope :to => "api/deprecated#index" do
    get "api_key"
    put "api_key/reset"

    post "gems"
    get  "gems/:id.json"

    scope :path => "gems/:rubygem_id" do
      put  "migrate"
      post "migrate"

      get    "owners(.:format)"
      post   "owners(.:format)"
      delete "owners(.:format)"
    end
  end

  ################################################################################
  # UI

  resource :search,    :only => :show
  resource :dashboard, :only => :show
  resource :profile,   :only => [:edit, :update]
  resources :stats,    :only => :index

  constraints :id => RUBYGEM_NAME_MATCHER do
    resources :rubygems, :path => "gems", :only => [:index, :show, :edit, :update] do
      resource :subscription, :only => [:create, :destroy]

      constraints :rubygem_id => RUBYGEM_NAME_MATCHER do
        resources :versions, :only => [:index, :show]
      end
    end
  end

  ################################################################################
  # Clearance Overrides

  resource :session, :only => :create
  scope :path => "users/:user_id" do
    resource :confirmation, :only => [:new, :create], :as => :user_confirmation
  end

  ################################################################################
  # Root

  root :to => "home#index"

end
