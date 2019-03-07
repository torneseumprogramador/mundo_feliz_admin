Rails.application.routes.draw do
  resources :pedidos do
  	resources :pedido_produtos
  end
  resources :clientes
  resources :produtos
  root to: 'home#index'
  get '/home', to: 'home#index'
  resources :tipo_produtos
end
