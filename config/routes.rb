Spree::Core::Engine.add_routes do
  
  post '/razorpay/create_order', to: 'razorpay#create_order'
  #Accept both POST and PATCH
  match '/razorpay/response', to: 'razorpay#razor_response', via: [:post, :patch], as: :razorpay_response
end
