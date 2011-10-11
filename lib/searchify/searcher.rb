module Searchify
  class Searcher
    attr_accessor :facets
    
    def initialize(model_class, *options)
      @model_class = model_class
      @facets = FacetsBuilder.build(model_class, options)
      @options = options
    end
    
    def search(options)
      @model_class.paginate(paginated_search_options(options))
    end
    
    private
    
    def paginated_search_options(options)
      search_options = SearchOptions.new(@facets, options).for_paginate
      search_options[:include] = association_names if association_names.present?
      search_options
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
