class AccountsController < ApplicationController
  add_crumb "Signup"

  def new
    @user = ApiUser.new
  end

  def create
    @user = ApiUser.new(params[:api_user])

    # Safe safely to be absolutely positive the save succeeded.
    if @user.with(:safe => true).save
      respond_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  def terms
    render(:layout => "popup")
  end
end
