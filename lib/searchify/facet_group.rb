module Searchify
  class FacetGroup < Facet
    attr_accessor :children
    
    def initialize(*args)
      @children = []
      super
    end
    
    def add_child(child)
      @children << child
    end
  end
end
