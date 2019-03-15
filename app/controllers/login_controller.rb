class LoginController < ApplicationController
  skip_before_action :verify_authenticity_token, :valida_logado_admin
  layout "login"

  def index;end

  def logar
    administradores = Administrador.where(email: params[:email], senha: params[:senha])
    if administradores.count > 0
      administrador = administradores.first
      time = params[:lembrar] == "1" ? 1.year.from_now : 30.minutes.from_now
      value = {
        id: administrador.id,
        nome: administrador.nome,
        email: administrador.email
      }
      cookies[:mundo_feliz_admin] = { value: value.to_json, expires: time, httponly: true }
      
      redirect_to "/admin"
    else
      flash[:error] = "Email ou senha inválidos"
      redirect_to "/login"
    end
  end

  def sair
    cookies[:mundo_feliz_admin] = nil
    redirect_to "/login"
  end

end