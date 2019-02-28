require "application_system_test_case"

class TipoProdutosTest < ApplicationSystemTestCase
  setup do
    @tipo_produto = tipo_produtos(:one)
  end

  test "visiting the index" do
    visit tipo_produtos_url
    assert_selector "h1", text: "Tipo Produtos"
  end

  test "creating a Tipo produto" do
    visit tipo_produtos_url
    click_on "New Tipo Produto"

    fill_in "Nome", with: @tipo_produto.nome
    click_on "Create Tipo produto"

    assert_text "Tipo produto was successfully created"
    click_on "Back"
  end

  test "updating a Tipo produto" do
    visit tipo_produtos_url
    click_on "Edit", match: :first

    fill_in "Nome", with: @tipo_produto.nome
    click_on "Update Tipo produto"

    assert_text "Tipo produto was successfully updated"
    click_on "Back"
  end

  test "destroying a Tipo produto" do
    visit tipo_produtos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tipo produto was successfully destroyed"
  end
end
