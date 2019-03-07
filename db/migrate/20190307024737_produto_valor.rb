class ProdutoValor < ActiveRecord::Migration[5.2]
  def change
  	add_column :produtos, :valor, :float
  end
end
