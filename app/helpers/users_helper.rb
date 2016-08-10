module UsersHelper

  def admin?
    current_user.admin?
  end

  def avatar(user, size = 100, klass = nil)
    default_url = "#{root_url}images/guest.png"
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    content_tag(:div, :class => "avatar-container #{klass}") do
      image_tag "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&d=mm",
        :class => 'avatar'
    end
  end

  def site_admin?(user = current_user)
    su = user.site_users.find_by(:site => current_site)
    return su.site_admin? unless su.nil?
    false
  end

  def all_site_users
    @all_site_users ||= begin
      (
        current_site.users.includes(:site_users) +
        User.admins.includes(:site_users)
      ).flatten.sort_by(&:last_name).unshift(current_user).uniq
    end
  end

  def is_current_user?
    @user == current_user
  end

  def current_site_user
    @current_site_user ||= begin
      current_user.site_users.find_by(:site => current_site,
                                      :user => current_user)
    end
  end

  def quick_user_status(user)
    if user.admin?
      link_to('', '#', :class => 'disabled admin')
    else
      link_to('', '#', :class => 'disabled user')
    end
  end

  def has_admin_access?(user = current_user, site = current_site)
     current_user.admin? || current_site_user.site_admin?
  end

  def user_status_filters
    o = link_to(
      "All",
      builder_site_users_path(current_site, :user_status => 'all'),
      :class => params[:user_status] == 'all' ? 'active' : nil
    )
    o += link_to(
      "Admins",
      builder_site_users_path(current_site, :user_status => 'admin'),
      :class => "admin
        #{params[:user_status] == 'admin' ? 'active' : nil}"
    )
    o += link_to(
      "Site Users",
      builder_site_users_path(current_site, :user_status => 'site_user'),
      :class => "user
        #{params[:user_status] == 'site_user' ? 'active' : nil}"
    )
    o.html_safe
  end

  def users_breadcrumbs
    o = link_to("all users", builder_route([all_site_users], :index))
    if @user
      o += content_tag(:span, '/', :class => 'separator')
      if @user.email.blank?
        o += link_to(
          "new user",
          builder_route([@user], :new)
        )
      else
        o += link_to(
          @user.display_name.downcase,
          builder_route([@user], :edit)
        )
      end
    end
    o.html_safe
  end

end
