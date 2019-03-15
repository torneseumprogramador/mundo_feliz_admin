class ApplicationController < ActionController::Base
  before_action :valida_logado_admin
  
  def valida_logado_admin
    if cookies[:mundo_feliz_admin].present?
      hash_admin = JSON.parse(cookies[:mundo_feliz_admin])
      if hash_admin["id"].present?
        administradores = Administrador.where(id: hash_admin["id"])
        if administradores.count > 0
          @administrador = administradores.first
          return
        end
      end
    end

    redirect_to "/login"
  end

end
