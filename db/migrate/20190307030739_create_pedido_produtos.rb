class CreatePedidoProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :pedido_produtos do |t|
      t.references :pedido, foreign_key: true
      t.references :produto, foreign_key: true
      t.float :valor
      t.integer :quantidade

      t.timestamps
    end
  end
end
