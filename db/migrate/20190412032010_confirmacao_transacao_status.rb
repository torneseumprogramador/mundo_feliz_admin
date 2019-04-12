class ConfirmacaoTransacaoStatus < ActiveRecord::Migration[5.2]
  def change
  	add_column :pedidos, :status, :string
  end
end
