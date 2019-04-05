class Cliente < ApplicationRecord
  validates :nome, :cpf, :telefone, :email, :senha, presence: true

  def nome_tratado
    self.nome.split(" ").first
  end

  def sobrenome
    nome = self.nome.split(" ").first
    sobrenome = self.nome.split(" ").last
    return "" if nome == sobrenome
    sobrenome
  end
end
