module Searchify
  class SearchOptions
    def initialize(facets, options)
      @facets = facets
      @options = options.symbolize_keys
    end
    
    def for_paginate
      options = {:page => page_option}
      options[:conditions] = conditions_option if conditions_option.present?
      options[:order] = order_option if order_option.present?
      options[:per_page] = per_page_option if per_page_option.present?
      options
    end
    
    def conditions_option
      ConditionsMerger.merge(conditions_array)
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
    
    def conditions_array
      @facets.map do |facet|
        facet.conditions_for_raw_options(@options)
      end
    end
    
    def facet_with_name(name)
      @facets.detect { |f| f.key_name == name.to_s }
    end
  end
end
