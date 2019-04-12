# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


cartão teste valido
4111111111111111



gem 'iugu'



  def iugo_initialize
    Iugu.api_key = IUGO_KEY
  end

iugo_initialize


            customer = create_iugo_customer(@usuario)


  def create_iugo_payment_method(customer, usuario, token)
    customer.payment_methods.create({
      description: "Cartão #{usuario.nome} - #{usuario.email}",
      token: token
    })
  end

  def create_iugo_customer(usuario)
    if usuario.iugo_customer_id.blank?
      customer = Iugu::Customer.create({
        email: usuario.email,
        name: usuario.nome,
        notes: "Cartão para ser usado em compras maratonavirtual, email #{usuario.email}"
      })

      begin
        usuario.iugo_customer_id = customer.id
        usuario.save!
      rescue
        raise "Problemas ao transacionar o seu cartão, por favor entre em contato com o suporte."
      end
    else
      customer = Iugu::Customer.fetch(usuario.iugo_customer_id)
    end

    return customer
  end

  def iugo_pagamento(usuario, payment_method, descricao, valor, usuario_endereco=nil, months=1)
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

    return payment_retorn
  end
end

            customer = create_iugo_customer(@usuario)
            payment_method = create_iugo_payment_method(customer, @usuario, pedido_hash[:token])

            if payment_method.errors.present?
              raise "#{payment_method.errors.inspect} - #{pedido_hash[:token]}"
            end


            pedido_hash[:cartao_id] = payment_method.id
          end

          if pedido_hash[:cartao_id].present?
            results = Iugu::PaymentMethod.search({customer_id: @usuario.iugo_customer_id}).results
            payment_method = results.find{|r|r.id == pedido_hash[:cartao_id]}
          else
            if @usuario.cpf_cnpj.blank?
              raise "Obrigatório o preenchimento do CPF para gerar boleto."
            end
          end


          payment_retorn = iugo_pagamento(@usuario, payment_method, "Pagamento pedido - #{pedido.id}", valor, usuario_endereco, pedido_hash[:parcelas])



         if payment_retorn.respond_to?(:identification) && payment_retorn.identification.present?
            pedido.boleto_pdf = payment_retorn.pdf
            pedido.boleto_numero = payment_retorn.identification
            pedido.invoice_id = payment_retorn.invoice_id
            pedido.status = Pedido::STATUS[:aguardando]
            pedido.data_vencimento_boleto = Time.zone.now + 3.days
            pedido.save!


          else
            if payment_retorn.respond_to?(:invoice_id) && payment_retorn.invoice_id.present?
              pedido.status = Pedido::STATUS[:pago]
              pedido.muda_status_pago = Time.zone.now
              pedido.invoice_id = payment_retorn.invoice_id
              pedido.save!

            end





















            
  def status_webhook
    if params[:data].present? && params[:data][:id].present?
      pedidos = Pedido.where(invoice_id: params[:data][:id])
      historico_invoices = PedidoInvoiceId.where(invoice_id: params[:data][:id])
      if pedidos.count > 0 || historico_invoices.count > 0
        if params[:data][:status] == "paid"
          pedido = pedidos.first
          pedido = historico_invoices.first.pedido if historico_invoices.count > 0 && pedidos.count == 0

          Pedido.where(id: pedido.id).update_all(status: Pedido::STATUS[:pago])
          pedido.status = Pedido::STATUS[:pago]
          pedido.muda_status_pago = Time.zone.now
          pedido.save

          pedido.usuario.envia_boleto_gerado

          render json: {}, status: 204
          return
        elsif params[:data][:status] == "expired" || params[:data][:status] == "canceled"
          if pedidos.count > 0
            pedido = pedidos.first
            
            if params[:data][:status] == "canceled"
              pedido = Pedido.find(pedido.id)
              if pedido.data_vencimento_boleto.present?
                if pedido.data_vencimento_boleto < Time.zone.now
                  Pedido.where(id: pedido.id).update_all(status: Pedido::STATUS[:aguardando])   
                end
              else
                Pedido.where(id: pedido.id).update_all(status: Pedido::STATUS[:aguardando])   
              end
            end  

            render json: {}, status: 204
            return
          end
        end
      else
        grupo_corrida_pagamentos = GrupoCorridaPagamento.where(invoice_id: params[:data][:id])
        historico_invoices = GrupoCorridaPagamentoInvoiceId.where(invoice_id: params[:data][:id])
        if grupo_corrida_pagamentos.count > 0 || historico_invoices.count > 0
          grupo_corrida_pagamento = grupo_corrida_pagamentos.first
          grupo_corrida_pagamento = historico_invoices.first.grupo_corrida_pagamento if historico_invoices.count > 0 && grupo_corrida_pagamentos.count == 0
          if grupo_corrida_pagamento.present?
            if params[:data][:status] == "paid" && grupo_corrida_pagamento.status != GrupoCorridaPagamento::PAGO
              begin
                ActiveRecord::Base.transaction do
                  grupo_corrida_pagamento.grupo_corrida.desafios.each do |desafio|
                    desafios_fazer = DesafiosFazer.new
                    desafios_fazer.desafio = desafio
                    desafios_fazer.usuario = grupo_corrida_pagamento.usuario
                    desafios_fazer.save!
                  end
                  grupo_corrida_pagamento.status = GrupoCorridaPagamento::PAGO
                  grupo_corrida_pagamento.save
                  grupo_corrida_pagamento.usuario.envia_boleto_gerado
                end
              rescue
                render json: {}, status: 401
                return
              end
              render json: {}, status: 204
              return;
            elsif params[:data][:status] == "expired" || params[:data][:status] == "canceled"
              if params[:data][:status] == "canceled"
                if grupo_corrida_pagamentos.count > 0
                  grupo_corrida_pagamento = grupo_corrida_pagamentos.first
                  GrupoCorridaPagamento.where(id: grupo_corrida_pagamento.id).update_all(status: GrupoCorridaPagamento::NAO_PAGO)     
                end
              end  

              render json: {}, status: 204
              return
            end
          end
        end
      end
    end

    render json: {}, status: 404
  rescue Exception => erro
    log = "Erro ao fechar pedido ou transacionar pagamento boleto: #{params.inspect} - #{erro.message} - #{erro.backtrace}"
    LogDelete.create(log: log)
    UsuarioMailer.envio_erro_pedido(params.inspect, log).deliver
    render json: {}, status: 404
  end
