class Api::V1::UsersController < Api::V1::BaseController
  respond_to :json

  def show
    @api_user = ApiUser.find(params[:id])
  end

  def create
    @api_user = ApiUser.new
    save!

    if(@api_user.errors.blank? && params[:user][:send_welcome_email])
      ApiUserMailer.delay(:queue => "mailers").signup_email(@api_user)
    end

    respond_to do |format|
      if(@api_user.save)
        format.json { render("show", :status => :created, :location => api_v1_user_url(@api_user)) }
      else
        format.json { render(:json => { :errors => @api_user.errors }, :status => :unprocessable_entity) }
      end
    end
  end

  def update
    @api_user = ApiUser.find(params[:id])
    save!

    respond_to do |format|
      if(@api_user.save)
        format.json { render("show", :status => :ok, :location => api_v1_user_url(@api_user)) }
      else
        format.json { render(:json => { :errors => @api_user.errors }, :status => :unprocessable_entity) }
      end
    end
  end

  private

  def save!
    before_roles = @api_user.roles || []

    @api_user.no_domain_signup = true
    @api_user.assign_nested_attributes(params[:user], :as => :admin)

    after_roles = @api_user.roles || []
    all_roles = before_roles + after_roles

    # FIXME: Temporary hack to prevent other admins from assign some specific
    # roles. This should be removed once we have more granular admin
    # permissions more robustly implemented.
    if(all_roles.any? { |role| role.include?("whitehouse") })
      if(@current_admin.username !~ /(eop.gov$|^nick.muerdter@nrel.gov$)/)
        @api_user.errors[:roles] << "You are unauthorized to make changes to users with this role."
        raise Mongoid::Errors::Validations.new(@api_user)
      end
    end

    if(@api_user.new_record?)
      @api_user.registration_source = "web_admin"
    end
  end
end
