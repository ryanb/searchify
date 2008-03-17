module Searchify
  class Searcher
    attr_accessor :facets
    
    def initialize(model_class, *options)
      @model_class = model_class
      @facets = FacetsBuilder.build(model_class, options)
      @options = options
    end
    
    def search(options)
      search_options = SearchOptions.new(@facets, options)
      @model_class.paginate(search_options.for_paginate.merge(:include => include_options))
    end
    
    private
    
    def include_options
      association_names unless association_names.empty?
    end
    
    def association_names
      if @options.last.is_a? Hash
        @options.last.keys
      else
        []
      end
    end
  end
end
