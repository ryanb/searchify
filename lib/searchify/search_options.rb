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
        options = condition_options_for_facet(facet)
        facet.conditions(options) unless options.empty?
      end
    end
    
    def condition_options_for_facet(facet)
      facet_options = {}
      @options.select do |name, value|
        if name.to_s == facet.key_name # this could use some refactoring and move into facet
          facet_options[:value] = value
        elsif name.to_s.starts_with? "#{facet.key_name}_"
          facet_options[name.to_s.sub("#{facet.key_name}_", '').to_sym] = value
        end
      end
      facet_options
    end
    
    def facet_condition_options
      result = {}
      @facets.each do |facet|
        
        
        result[facet] = facet_conditions
      end
      result
    end
    
    def facet_with_name(name)
      @facets.detect { |f| f.key_name == name.to_s }
    end
  end
end
