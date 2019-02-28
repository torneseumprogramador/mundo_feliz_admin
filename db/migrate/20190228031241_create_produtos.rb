class CreateProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :produtos do |t|
      t.string :nome
      t.text :descricao
      t.integer :quantidade
      t.references :tipo_produto, foreign_key: true

      t.timestamps
    end
  end
end
