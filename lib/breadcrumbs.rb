class BreadCrumbs 
  ROUTES = {
    :home => '/',
    :artists => '/artists',
    :events => '/events',
    :press => '/press',
    :contact => '/contact'
  }

  def initialize(crumbs = [])
    @crumbs = crumbs.map{|c| {:url => ROUTES[c.to_sym], :display => c}}
  end

  def render
    html = ''
    template = []
    if @crumbs.count > 0
      template << "%ul.breadcrumbs\n"
      lastcrumb = @crumbs.count - 1
      @crumbs.each_with_index do |entry, idx|
        pth = entry[:url]
        disp = entry[:display]
        template << "  %li.crumb" + ((idx != lastcrumb) ? '': '.last') + "\n"
        if idx != lastcrumb
          template << "    %a{:href => \"#{pth}\"}\n"
          template << "      .name #{disp} &raquo;\n"
        else
          template << "    .name #{disp}\n"
        end
      end
    end
    Haml::Engine.new(template.join).render
  end
end
    
