module Searchify
  class SearchOptions
    def initialize(facets, options)
      @facets = facets
      @options = options
    end
    
    def for_paginate
      { :conditions => conditions_option, :order => order_option, :page => page_option, :per_page => per_page_option }
    end
    
    def conditions_option
      conditions = []
      @options.each do |name, value|
        conditions << facet_with_name(name).conditions(value) unless facet_with_name(name).nil?
      end
      ConditionsMerger.merge(conditions)
    end
    
    def order_option
      facet_with_name(@options[:order]).column_name if facet_with_name(@options[:order])
    end
    
    def page_option
      @options[:page] || 1
    end
    
    def per_page_option
      @options[:per_page]
    end
    
    private
    
    def facet_with_name(name)
      @facets.detect { |f| f.key_name == name.to_s }
    end
  end
end
