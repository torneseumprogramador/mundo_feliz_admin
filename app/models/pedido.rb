class Pedido < ApplicationRecord
  belongs_to :cliente
  has_many :pedido_produtos
end
