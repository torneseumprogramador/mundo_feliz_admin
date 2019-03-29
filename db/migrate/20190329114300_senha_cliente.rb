class SenhaCliente < ActiveRecord::Migration[5.2]
  def change
  	add_column :clientes, :senha, :string
  end
end
