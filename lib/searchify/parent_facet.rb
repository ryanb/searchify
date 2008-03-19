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
    
    def conditions(options)
      ConditionsMerger.merge(conditions_for_words(options[:value].split(/\s+/)), 'AND') unless options[:value].nil?
    end
    
    private
    
    def conditions_for_words(words)
      words.map do |word|
        ConditionsMerger.merge(conditions_for_word(word), 'OR')
      end
    end
    
    def conditions_for_word(word)
      children.map do |child|
        child.conditions(:contains => word)
      end
    end
  end
end
