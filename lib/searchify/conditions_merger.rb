module Searchify
  class ConditionsMerger
    def self.merge(*args)
      ConditionsMerger.new(*args).merge
    end
    
    def initialize(conditions, join = 'AND')
      @conditions = conditions
      @join = join
    end
    
    def merge
      ["(#{merge_string})", *merge_options] unless @conditions.compact.empty?
    end
    
    def merge_string
      @conditions.map do |condition|
        case condition
        when Array then condition.first
        when String then condition
        end
      end.compact.join(") #{@join} (")
    end
    
    def merge_options
      @conditions.map do |condition|
        condition[1..-1] if condition.kind_of? Array
      end.compact.flatten
    end
  end
end
