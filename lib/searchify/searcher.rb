module Searchify
  class Searcher
    attr_accessor :facets
    
    def initialize(model_class, *facet_names)
      @model_class = model_class
      @facets = FacetsBuilder.build(model_class, *facet_names)
    end
    
    def search(options)
      options[:page] ||= 1
      options[:conditions] = conditions(options)
      @model_class.paginate(options.slice(:page, :per_page, :conditions)) # security concern, don't pass conditions directly!
    end
    
    def conditions(options)
      conditions = []
      options.each do |name, value|
        conditions << facet_with_name(name).conditions(value) unless facet_with_name(name).nil?
      end
      ConditionsMerger.merge(conditions)
    end
    
    private
    
    def facet_with_name(name)
      @facets.detect { |f| f.name == name.to_s }
    end
  end
end
