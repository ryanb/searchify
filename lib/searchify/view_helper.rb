module Searchify
  module ViewHelper
    def searchify_fields_for(model_class)
      javascript_include_tag('searchify') + content_tag(:div, '', :id => 'searchify') + javascript_tag("searchify(#{model_class.searchify_facets.to_json})")
    end
  end
end

class ActionView::Base
  include Searchify::ViewHelper
end
