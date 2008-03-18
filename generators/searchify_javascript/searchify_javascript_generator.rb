class SearchifyJavascriptGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "searchify.js", "public/javascripts/searchify.js"
    end
  end
end
