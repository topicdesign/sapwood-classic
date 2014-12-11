class Builder::SitesController < BuilderController

  before_filter :set_layout_options

  def index
  end

  def show
    redirect_to route([current_site], :edit, 'builder')
  end

  def new
    @current_site = Site.new
  end

  def create
    @current_site = Site.new(create_params)
    if current_site.save
      if params[:site][:new_repo].to_bool
        create_taproot_project
      end
      SiteUser.create!(
        :user => current_user, 
        :site => current_site, 
        :site_admin => true
      )
      redirect_to(
        route([current_site], :show, 'builder'), 
        :notice => t('notices.created', :item => "Site")
      ) 
    else
      render('new')
    end
  end

  def edit
    current_site = current_site
  end

  def update
    if current_site.update(update_params)
      redirect_to(route([current_site], :edit, 'builder'), 
        :notice => t('notices.updated', :item => "Site")) 
    else
      render('edit')
    end
  end

  def destroy
    taproot = TaprootProject.new(current_site)
    taproot.remove_files
    current_site.destroy
    redirect_to(builder_sites_path, :notice => 'Site deleted successfully.')
  end

  def git
    # ISSUE #2
    # TODO: Queue the site for pulling and restarting the server
  end

  private

    def create_params
      params.require(:site).permit(
        :title, 
        :url, 
        :description,
        :home_page_id,
        :git_path,
        :local_repo,
        :image_croppings_attributes => [
          :id, 
          :title,
          :ratio,
          :min_width,
          :min_height
        ]
      )
    end

    def update_params
      create_params
    end

    def set_layout_options
      if ['index', 'new', 'create'].include?(action_name)
        @options['sidebar'] = false
        @options['body_classes'] += ' my-sites'
      end
    end

    def create_taproot_project
      taproot = TaprootProject.new(current_site)
      taproot.create_site
    end

end
