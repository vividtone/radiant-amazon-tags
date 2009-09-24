# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class AmazonTagsExtension < Radiant::Extension
  version "1.0"
  description "Tags for Amazon Product Advertising API"
  url "http://www.farend.co.jp/"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :amazon_tags
  #   end
  # end
  
  def activate
    # admin.tabs.add "Amazon Tags", "/admin/amazon_tags", :after => "Layouts", :visibility => [:all]

    Page.send :include, AmazonTags
  end
  
  def deactivate
    # admin.tabs.remove "Amazon Tags"
  end

end
