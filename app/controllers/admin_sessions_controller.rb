class AdminSessionsController < Devise::SessionsController
  def new
    provider = if(Rails.env.development?) then "developer" else "cas" end
    redirect_to(admin_omniauth_authorize_path(:provider => provider))
  end
end
