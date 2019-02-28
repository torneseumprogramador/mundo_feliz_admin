require 'test_helper'

class TipoProdutosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tipo_produto = tipo_produtos(:one)
  end

  test "should get index" do
    get tipo_produtos_url
    assert_response :success
  end

  test "should get new" do
    get new_tipo_produto_url
    assert_response :success
  end

  test "should create tipo_produto" do
    assert_difference('TipoProduto.count') do
      post tipo_produtos_url, params: { tipo_produto: { nome: @tipo_produto.nome } }
    end

    assert_redirected_to tipo_produto_url(TipoProduto.last)
  end

  test "should show tipo_produto" do
    get tipo_produto_url(@tipo_produto)
    assert_response :success
  end

  test "should get edit" do
    get edit_tipo_produto_url(@tipo_produto)
    assert_response :success
  end

  test "should update tipo_produto" do
    patch tipo_produto_url(@tipo_produto), params: { tipo_produto: { nome: @tipo_produto.nome } }
    assert_redirected_to tipo_produto_url(@tipo_produto)
  end

  test "should destroy tipo_produto" do
    assert_difference('TipoProduto.count', -1) do
      delete tipo_produto_url(@tipo_produto)
    end

    assert_redirected_to tipo_produtos_url
  end
end
