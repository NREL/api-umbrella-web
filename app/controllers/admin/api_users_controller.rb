class Admin::ApiUsersController < Admin::BaseController
  set_tab :users

  add_crumb "API Users", :admin_api_users_path
  add_crumb "New User", :only => [:new, :create]
  add_crumb "Edit User", :only => [:edit, :update]

  def index
    @api_users = ApiUser.desc(:created_at).page(params[:page])

    if(params[:search].present?)
      @api_users = @api_users.or([
        { :first_name => /#{params[:search]}/i },
        { :last_name => /#{params[:search]}/i },
        { :email => /#{params[:search]}/i },
        { :api_key => /#{params[:search]}/i },
      ])
    end
  end

  def new
    @api_user = ApiUser.new
  end

  def edit
    @api_user = ApiUser.find(params[:id])
  end

  def create
    @api_user = ApiUser.new
    save!

    flash[:success] = %(Successfully created user account.<br>E-mail: #{@api_user.email}<br>API Key: <span class="api-key">#{@api_user.api_key}</span>).html_safe
    redirect_to(admin_api_users_path)
  rescue Mongoid::Errors::Validations
    logger.info($!.inspect)
    logger.info(@api_user.errors.inspect)
    render(:action => "new")
  end

  def update
    @api_user = ApiUser.find(params[:id])
    save!

    flash[:success] = "Successfully updated user account"
    redirect_to(admin_api_users_path)
  rescue Mongoid::Errors::Validations
    render(:action => "edit")
  end

  private

  def save!
    before_roles = @api_user.roles || []

    @api_user.assign_attributes(params[:api_user], :as => :admin)

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

    @api_user.save!
  end
end
