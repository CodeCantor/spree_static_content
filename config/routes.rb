module StaticPage
  def self.remove_spree_mount_point(path)
    regex = Regexp.new '\A' + Rails.application.routes.url_helpers.spree_path
    path.sub( regex, '').split('?')[0]
  end
end

class Spree::StaticPage

  class << self

    def matches? request
      return false if request.path =~ /(^\/+(admin|account|cart|checkout|content|login|pg\/|orders|products|s\/|session|signup|shipments|states|t\/|tax_categories|user)+)/
      Spree::Page.visible.exists?(slug: extract_slug_from_path(request.path))
    end

    def extract_slug_from_path path
      path.split('/').reject do |part|
        part.blank? || I18n.available_locales.include?(part)
      end
    end
  end
end

class Spree::StaticRoot
  def self.matches?(request)
    path = StaticPage::remove_spree_mount_point(request.fullpath)
    path.nil? && Spree::Page.visible.by_slug(path.to_s).first
  end
end

Spree::Core::Engine.add_routes do

  namespace :admin do
    resources :pages
  end

  constraints(Spree::StaticRoot) do
    get '/', :to => 'static_content#show'
  end

  constraints(Spree::StaticPage) do
    get '/*path', :to => 'static_content#show'
  end
end
