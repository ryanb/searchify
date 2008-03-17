module Searchify
  class Searcher
    attr_accessor :facets
    
    def initialize(model_class, *options)
      @model_class = model_class
      @facets = FacetsBuilder.build(model_class, options)
      @options = options
    end
    
    def search(options)
      options[:page] ||= 1
      options[:conditions] = conditions(options)
      options[:order] = order(options)
      @model_class.paginate(options.slice(:page, :per_page, :conditions, :order).merge(:include => include_options)) # security concern, don't pass conditions directly!
    end
    
    def conditions(options)
      conditions = []
      options.each do |name, value|
        conditions << facet_with_name(name).conditions(value) unless facet_with_name(name).nil?
      end
      ConditionsMerger.merge(conditions)
    end
    
    def order(options)
      facet_with_name(options[:order]).column_name if facet_with_name(options[:order])
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
    
    def facet_with_name(name)
      @facets.detect { |f| f.key_name == name.to_s }
    end
  end
end
