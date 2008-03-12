module Searchify
  module ModelAdditions
    def searchify
      @searcher = Searchify::Searcher.new(self)
      extend GeneratedMethods
    end
    
    module GeneratedMethods
      def searcher
        @searcher
      end
      
      def search(options = {})
        searcher.search(options)
      end
    end
  end
end

class ActiveRecord::Base
  extend Searchify::ModelAdditions
end
