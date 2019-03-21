Rails.application.routes.draw do
  resources :administradors
  resources :pedidos do
  	resources :pedido_produtos
  end
  resources :clientes
  resources :produtos
  resources :tipo_produtos

  get '/admin', to: 'admin#index'
  get '/login', to: 'login#index'
  post '/login/logar', to: 'login#logar'
  get '/login/sair', to: 'login#sair'

  get '/produto/:produto_id', to: 'produto#index'
  get '/produto/:produto_id/adicionar', to: 'produto#adicionar'
  get '/produto/:produto_id/remover', to: 'produto#remover'
  get '/carrinho', to: 'produto#carrinho'

  root to: 'home#index'

end
