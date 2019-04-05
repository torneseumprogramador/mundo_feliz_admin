class IugoCustomerId < ActiveRecord::Migration[5.2]
  def change
  	add_column :clientes, :iugo_customer_id, :string
  end
end
