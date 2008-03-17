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
    
    def add_children(children)
      @children += children
    end
    
    def conditions(value)
      merge_conditions textual_children.map { |c| c.conditions(value) }
    end
    
    private
    
    def merge_conditions(conditions)
      ConditionsMerger.merge(conditions, 'OR')
    end
    
    def textual_children
      @children.select { |c| c.type == :text }
    end
  end
end
