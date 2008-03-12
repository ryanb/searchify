module Searchify
  class ParentFacet < Facet
    attr_accessor :children
    
    def initialize(*args)
      @children = []
      super
    end
    
    def add_child(child)
      @children << child
    end
    
    def conditions(value)
      merge_conditions @children.map { |c| c.conditions(value) }
    end
    
    def merge_conditions(conditions)
      if conditions.empty? 
        nil
      else
        [conditions.transpose.first.join(' AND '), *conditions.transpose.last]
      end
    end
  end
end
