Gem::Specification.new do |s|
  s.name        = "searchify"
  s.version     = "0.0.1.alpha"
  s.author      = "Ryan Bates"
  s.email       = "ryan@railscasts.com"
  s.homepage    = "http://github.com/ryanb/searchify"
  s.summary     = "Add fields to search models."
  s.description = "This is a Rails plugin which adds some search functionality to models. It also includes a JavaScript file and helper methods for building a dynamic search form. Currently Prototype only."

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  # s.add_development_dependency 'rspec', '~> 2.6.0'
  # s.add_development_dependency 'rails', '~> 3.0.9'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
