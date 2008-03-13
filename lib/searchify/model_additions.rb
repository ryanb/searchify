module Searchify
  module ModelAdditions
    def searchify(*args)
      @searcher = Searchify::Searcher.new(self, *args)
      extend GeneratedMethods
    end
    
    module GeneratedMethods
      def searcher
        @searcher
      end
      
      def search(options = {})
        searcher.search(options)
      end
      
      def searchify_facets
        searcher.facets
      end
    end
  end
end

class ActiveRecord::Base
  extend Searchify::ModelAdditions
end
