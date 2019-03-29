class EcommerceController < ApplicationController
  skip_before_action :valida_logado_admin
  skip_before_action :verify_authenticity_token

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

  def fechar_carrinho
    if cookies[:cliente_login].blank?
      redirect_to "/cliente/logar"
      return
    end

    if cookies[:carrinho].blank?
      redirect_to "/"
      return
    end

    produtos = JSON.parse(cookies[:carrinho]);
    @produtos = Produto.where(id: produtos)
  end

  def login
  end

  def fazer_login_cliente
    clientes = Cliente.where(email: params[:email], senha: params[:senha])
    if clientes.count > 0
      cliente = clientes.first
      time = params[:lembrar] == "1" ? 1.year.from_now : 30.minutes.from_now
      value = {
        id: cliente.id,
        nome: cliente.nome,
        email: cliente.email
      }
      cookies[:cliente_login] = { value: value.to_json, expires: time, httponly: true }
      
      redirect_to "/carrinho/fechar"
    else
      flash[:error] = "Email ou senha inválidos"
      redirect_to "/cliente/logar"
    end
  end

  def cadastrar
    if cookies[:cliente_login].blank?
      @cliente = Cliente.new
    else
      c = JSON.parse(cookies[:cliente_login]);
      @cliente = Cliente.find(c["id"])
    end
  end

  def sair
    cookies[:cliente_login] = nil
    redirect_to "/"
  end

  def cadastrar_cliente
    if cookies[:cliente_login].blank?
      @cliente = Cliente.new(cliente_params)
      if @cliente.save
        cookies[:cliente_login] = { 
          value: {
            id: @cliente.id,
            nome: @cliente.nome,
            email: @cliente.email
          }.to_json,
          expires: 1.year.from_now, httponly: true 
        }
        redirect_to "/carrinho/fechar"
      else
        render :cadastrar
      end
    else
      c = JSON.parse(cookies[:cliente_login]);
      @cliente = Cliente.find(c["id"])
      if @cliente.update(cliente_params)
        cookies[:cliente_login] = { 
          value: {
            id: @cliente.id,
            nome: @cliente.nome,
            email: @cliente.email
          }.to_json,
          expires: 1.year.from_now, httponly: true 
        }
        flash[:success] = "Dados atualizados"
        redirect_to "/cliente/cadastrar"
      else
        render :cadastrar
      end
    end
  end

  private
    def cliente_params
      params.require(:cliente).permit(:nome, :cpf, :telefone, :email, :cep, :endereco, :numero, :bairro, :cidade, :estado, :senha)
    end
end
