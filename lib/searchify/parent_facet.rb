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
      merge_conditions textual_children.map { |c| c.conditions(value) }
    end
    
    private
    
    def merge_conditions(conditions)
      if conditions.empty? 
        nil
      else
        [conditions.transpose.first.join(' OR '), *conditions.transpose.last]
      end
    end
    
    def textual_children
      @children.select { |c| c.type == :text }
    end
  end
end
