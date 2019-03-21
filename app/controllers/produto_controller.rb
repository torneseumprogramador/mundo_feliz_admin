class ProdutoController < ApplicationController
  skip_before_action :valida_logado_admin
  layout "site"

  def index
    @produto = Produto.find(params[:produto_id])
  end

  def adicionar
    if cookies[:carrinho].present?
      produtos = JSON.parse(cookies[:carrinho]);
    else
      produtos = []
    end

    produtos << params[:produto_id]
    produtos.uniq!
    cookies[:carrinho] = { value: produtos.to_json, expires: 1.year.from_now, httponly: true }
    redirect_to "/"
  end

  def remover
    if cookies[:carrinho].blank?
      redirect_to "/"
      return
    end

    produtos = JSON.parse(cookies[:carrinho]);
    produtos.delete(params[:produto_id])
    cookies[:carrinho] = { value: produtos.to_json, expires: 1.year.from_now, httponly: true }
    redirect_to "/carrinho"
  end

  def carrinho
    if cookies[:carrinho].blank?
      redirect_to "/"
      return
    end

    produtos = JSON.parse(cookies[:carrinho]);
    @produtos = Produto.where(id: produtos)
  end
end
