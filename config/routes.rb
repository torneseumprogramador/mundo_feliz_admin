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

  get '/produto/:produto_id', to: 'ecommerce#index'
  get '/produto/:produto_id/adicionar', to: 'ecommerce#adicionar'
  get '/produto/:produto_id/remover', to: 'ecommerce#remover'
  get '/carrinho', to: 'ecommerce#carrinho'
  get '/carrinho/fechar', to: 'ecommerce#fechar_carrinho'
  get '/cliente/logar', to: 'ecommerce#login'
  post '/cliente/login', to: 'ecommerce#fazer_login_cliente'
  get '/cliente/cadastrar', to: 'ecommerce#cadastrar'
  post '/cliente/criar', to: 'ecommerce#cadastrar_cliente'
  patch '/cliente/criar', to: 'ecommerce#cadastrar_cliente'
  get '/cliente/compra-concluida', to: 'ecommerce#compra_concluida'
  get '/cliente/seu-boleto', to: 'ecommerce#boleto_gerado'
  get '/cliente/sair', to: 'ecommerce#sair'
  post '/cliente/concluir-pagamento', to: 'ecommerce#concluir_pagamento'

  get '/cliente/pagamento', to: 'ecommerce#confirmar_pagamento'


  root to: 'home#index'

end
