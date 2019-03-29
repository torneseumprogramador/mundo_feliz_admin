class Cliente < ApplicationRecord
  validates :nome, :cpf, :telefone, :email, :senha, presence: true
end
