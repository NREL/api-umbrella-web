class Admin::Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # For the developer strategy, simply find or create a new admin account with
  # whatever login details they give. This is not for use on production.
  def developer
    unless Rails.env.development?
      raise "The developer OmniAuth strategy should not be used outside of development."
    end

    omniauth = env["omniauth.auth"]
    @admin = Admin.where(:username => omniauth["uid"]).first
    @admin ||= Admin.new(:username => omniauth["uid"])
    @admin.apply_omniauth(omniauth)
    @admin.save!
    sign_in(:admin, @admin)
    redirect_to admin_path
  end

  def google_oauth2
    if(env["omniauth.auth"]["extra"]["raw_info"]["verified_email"])
      @email = env["omniauth.auth"]["info"]["email"]
    end

    login
  end

  def persona
    @email = env["omniauth.auth"]["info"]["email"]
    login
  end

  def cas
    @email = env["omniauth.auth"]["uid"]
    login
  end

  def myusa
    @email = env["omniauth.auth"]["info"]["email"]
    login
  end

  private

  def login
    if @email.present?
      @admin = Admin.where(:username => @email).first
    end

    if @admin
      @admin.last_sign_in_provider = env["omniauth.auth"]["provider"]
      @admin.email = env["omniauth.auth"]["info"]["email"]
      @admin.name = env["omniauth.auth"]["info"]["name"]
      @admin.save!

      sign_in_and_redirect(:admin, @admin)
    else
      flash[:error] = %(The account for '#{@email}' is not authorized to access the admin. Please <a href="#{contact_path}">contact us</a> for further assistance.).html_safe

      redirect_to new_admin_session_path
    end
  end
end
