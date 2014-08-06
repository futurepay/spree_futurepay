Spree::Core::Engine.routes.draw do
     
    namespace :admin do
        get "futurepay/index" => "futurepay#index"
        put "futurepay/create" => "futurepay#create"
        get "futurepay/create" => "futurepay#create"
    end
    
    get "checkout/payment/futurepay/confirm" => "futurepay#confirm"
      
    post "checkout/payment/futurepay" => "futurepay#preorder"
    
  namespace :admin do
    # Using :only here so it doesn't redraw those routes
    resources :orders, :only => [] do
      resources :payments, :only => [] do
        member do
          get 'futurepay_refund'
          post 'futurepay_refund'
        end
      end
    end
  end
  
  
end
