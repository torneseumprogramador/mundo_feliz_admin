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

  def concluir_pagamento
    Iugu.api_key = ""

    cliente = Cliente.find(params[:cliente_id])

    if usuario.iugo_customer_id.blank?
      customer = Iugu::Customer.create({
        email: cliente.email,
        name: cliente.nome,
        notes: "Cartão, email #{cliente.email}"
      })

      begin
        cliente.iugo_customer_id = customer.id
        cliente.save!
      rescue
        raise "Problemas ao transacionar o seu cartão, por favor entre em contato com o suporte."
      end
    else
      customer = Iugu::Customer.fetch(cliente.iugo_customer_id)
    end


    customer.payment_methods.create({
      description: "Cartão #{cliente.nome} - #{cliente.email}",
      token: params[:token]
    })

    valor = valor.gsub(",", ".").to_f if valor.is_a?(String)
    valor_centavos = (valor * 100).to_i
    months = "1" if months.blank?
    months = months.to_i rescue 1
    months = 1 if months < 1

    options = {
      "email"=>usuario.email,
      "months"=>months, # quantidade de parcelas
      "items" => [
        {
          "description" => descricao,
          "quantity" => "1",
          "price_cents"=> valor_centavos
        }
      ]
    }

    if payment_method.present?
      options["customer_payment_method_id"] = payment_method.id
    else
      if usuario_endereco.present?
        begin
          options["method"] = "bank_slip"
          options["payer"] = {
            "cpf_cnpj" => usuario_endereco.usuario.cpf_cnpj.gsub("-", "").gsub(".", ""),
            "name" => usuario_endereco.usuario.nome,
            "phone_prefix" => usuario_endereco.usuario.telefone[1,2],
            "phone" => usuario_endereco.usuario.telefone[4,20].gsub("-", ""),
            "email" => usuario_endereco.usuario.email,
            "address" => {
              "street" => usuario_endereco.endereco,
              "number" => usuario_endereco.numero,
              "city" => usuario_endereco.cidade,
              "district" => usuario_endereco.cidade,
              "state" => usuario_endereco.estado,
              "country" => "Brasil",
              "zip_code" => usuario_endereco.cep
            }
          }
        rescue Exception => erro
          puts "====================="
          puts "=========#{erro.message}============"
          puts "====================="
          puts "=========#{erro.backtrace}============"
          puts "====================="
          raise "Endereço, cpf_cnpj ou telefone não localizado para o pagamento com boleto"
        end
      # else
      #   raise "Endereço não localizado para o pagamento com boleto"
      end
    end

    payment_retorn = Iugu::Charge.create(options)

    if payment_retorn.errors.present?
      begin
        mensagem = payment_retorn.errors.map{|k,v| "#{k}: #{v.join(",")}"}.join(", ")
      rescue
        mensagem = payment_retorn.errors.inspect rescue "Erro ao fazer pagamento, tente novamente mais tarde"
      end
      raise mensagem
    else
      if payment_retorn.respond_to?(:LR)
        if payment_retorn.LR != "00"
          raise payment_retorn.message
        end
      else
        if payment_retorn.respond_to?(:identification) &&  payment_retorn.respond_to?(:success) && payment_retorn.success
          return payment_retorn
        else
          raise payment_retorn.message
        end
      end
    end

    payment_retorn

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
