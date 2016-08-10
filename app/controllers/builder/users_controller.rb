class Builder::UsersController < BuilderController

  before_action :set_user, :except => [:index, :create]
  before_filter :verify_admin

  def index
    @users = all_site_users
    if params[:user_status] && params[:user_status] != 'all'
      @users = @users.select { |t| t.send("#{params[:user_status]}?") }
    elsif params[:user_status] != 'all'
      redirect_to(
        builder_site_users_path(current_site, :user_status => 'all')
      )
    end
  end

  def new
    @site_user = SiteUser.find_by(:user => @user, :site => current_site)
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    @user = User.create!(create_params) if @user.nil?
    if @user.save
      site_users = SiteUser.where(:user => @user, :site => current_site)
      site_users.destroy_all if site_users.size > 1
      @site_user = SiteUser.find_or_initialize_by(:user => @user, :site => current_site)
      @site_user.site_admin = params[:user][:site_admin]
      if @site_user.save
        redirect_to(builder_route([@user], :index),
          :notice => t('notices.created', :item => "User"))
      else
        render 'new'
      end
    else
      render 'new'
    end
  end

  def edit
    @site_user = SiteUser.find_by(:user => @user, :site => current_site)
  end

  def update
    @user = User.find_by_id(params[:id])
    p ||= create_params
    if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
      p = create_params.except("password", "password_confirmation")
    end
    if @user.update(p)
      if @user == current_user && p[:password].present?
        sign_in(@user, :bypass => true)
      end
      unless @user.admin?
        site_users = SiteUser.where(:user => @user, :site => current_site)
        site_users.destroy_all if site_users.size > 1
        @site_user = SiteUser.find_or_initialize_by(:user => @user, :site => current_site)
        @site_user.site_admin = params[:user][:site_admin]
        @site_user.save!
      end
      redirect_to(
        builder_route([@user], :index),
        :notice => t('notices.updated', :item => "User")
      )
    else
      render 'edit'
    end
  end

  def destroy
    site_users = SiteUser.where(:user_id => params[:id])
    site_users.destroy_all
    redirect_to(builder_route([@user], :index),
      :notice => t('notices.deleted', :item => "User"))
  end

  private

    def set_user
      if action_name == 'new'
        @user = User.new(params[:user] ? create_params : nil)
      else
        @user = User.find_by_id(params[:id])
        unless @user.admin?
          @user = current_site.users.find_by_id(params[:id])
        end
      end
      not_found if @user.nil?
    end

    def create_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :admin
      )
    end

    def builder_html_title
      @builder_html_title ||= begin
        case action_name
        when 'index'
          "Users >> #{current_site.title}"
        when 'edit', 'update'
          set_user
          "Edit >> #{@user.display_name}"
        when 'new', 'create'
          "New User"
        end
      end
    end

end
