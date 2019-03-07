class Cliente < ApplicationRecord
  validates :nome, :cpf, :telefone, :email, presence: true
end
