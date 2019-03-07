json.extract! cliente, :id, :nome, :cpf, :telefone, :email, :cep, :endereco, :numero, :bairro, :cidade, :estado, :created_at, :updated_at
json.url cliente_url(cliente, format: :json)
