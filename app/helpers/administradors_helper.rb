module AdministradorsHelper
  def existe_carrinho?(id)
    return false if cookies[:carrinho].blank?
    produtos = JSON.parse(cookies[:carrinho]);
    produtos.include?(id.to_s)
  end
end
