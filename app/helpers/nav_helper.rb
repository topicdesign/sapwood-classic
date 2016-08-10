module NavHelper

  def read_nav_config(config)
    file = "#{Rails.root}/config/sapwood/#{config}.yml"
    return nil unless File.exists?(file)
    nav = {}
    YAML.load_file(file).each { |k,v| nav[k] = v.to_ostruct }
    nav
  end

  def builder_site_nav_config
    read_nav_config('builder_site_nav')
  end

  def builder_site_nav
    content_tag(:ul, :class => "#{'admin' if has_admin_access?}") do
      items = ''
      builder_site_nav_config.each do |item, attrs|
        if attrs.admin.blank? || (attrs.admin.to_bool == false) || has_admin_access?
          path = send(attrs.path, current_site)
          items += content_tag(
            :li,
            :class => builder_nav_active?(item, path, attrs.controllers) ? 'active' : nil
          ) { link_to(attrs.label, path) }
        end
      end
      items.html_safe
    end
  end

  def builder_nav_active?(item, path, controllers = [])
    if(
      request.path =~ /^#{path}/ && (
        controllers.include?(controller_name) || request.path == path
      )
    )
      @builder_nav_active_item = item
      true
    else
      false
    end
  end

  def sidebar(partial = 'sidebar')
    content_tag(:aside, :id => 'page-sidebar') { render(:partial => partial) }
  end

  def sidebar_item_active?(item)
    (item[:controllers] && item[:controllers].include?(controller_name)) ||
      request.path == item[:path]
  end

  def tab_active?(item)
    sidebar_item_active?(item)
  end

end
