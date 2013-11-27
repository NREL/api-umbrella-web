class Admin::ApiUsersController < Admin::BaseController
  respond_to :json
  set_tab :users

  add_crumb "API Users", :admin_api_users_path
  add_crumb "New User", :only => [:new, :create]
  add_crumb "Edit User", :only => [:edit, :update]

  def index
    limit = params[:iDisplayLength].to_i
    limit = 10 if(limit == 0)

    @api_users = ApiUser
      .order_by(datatables_sort_array)
      .skip(params[:iDisplayStart].to_i)
      .limit(limit)

    if(params[:sSearch].present?)
      @api_users = @api_users.or([
        { :first_name => /#{params[:sSearch]}/i },
        { :last_name => /#{params[:sSearch]}/i },
        { :email => /#{params[:sSearch]}/i },
        { :api_key => /#{params[:sSearch]}/i },
        { :_id => /#{params[:sSearch]}/i },
      ])
    end
  end

  def show
    @api_user = ApiUser.find(params[:id])
  end

  def create
    @api_user = ApiUser.new
    save!
    respond_with(:admin, @api_user, :root => "api_user")
  end

  def update
    @api_user = ApiUser.find(params[:id])
    save!
    respond_with(:admin, @api_user, :root => "api_user")
  end

  private

  def save!
    before_roles = @api_user.roles || []

    @api_user.no_domain_signup = true;
    @api_user.assign_nested_attributes(params[:api_user], :as => :admin)

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

    @api_user.save
  end
end
