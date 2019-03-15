class HomeController < ApplicationController
  skip_before_action :valida_logado_admin
  layout "site"

  def index
  	@produtos = Produto.all
  end
end
