class ConfirmacaoTransacao < ActiveRecord::Migration[5.2]
  def change
  	add_column :pedidos, :transacao_id, :string
  	add_column :pedidos, :numero_boleto, :string
  	add_column :pedidos, :pdf_boleto, :string
  end
end
