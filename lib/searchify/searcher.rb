module Searchify
  class Searcher
    attr_accessor :facets
    
    def initialize(model_class, *args)
      @model_class = model_class
      @facets = []
      build_facets(args)
    end
    
    def search(options)
      options[:page] ||= 1
      options[:conditions] = conditions(options)
      @model_class.paginate(options.slice(:page, :per_page, :conditions)) # security concern, don't pass conditions directly!
    end
    
    def conditions(options)
      conditions = []
      options.each do |name, value|
        if name.to_sym == :all
          @facets.each do |facet|
            conditions << ["mocked_models.#{facet.name} LIKE ?", value] unless facet.all?
          end
        else
          conditions << ["mocked_models.#{name} LIKE ?", value] if column_name?(name)
        end
      end
      if conditions.empty?
        nil
      else
        [conditions.transpose.first.join(' AND '), *conditions.transpose.last]
      end
    end
    
    private
    
    def build_facet(*args)
      Facet.new(@model_class, *args)
    end
    
    def build_facets(args)
      args.each do |arg|
        if arg.to_sym == :all
          build_all_facets
        elsif column_name?(arg)
          @facets << build_facet(arg)
        else
          raise "Argument '#{arg}' does not match any column for the model"
        end
      end
    end
    
    def build_all_facets
      @facets << build_facet(:all, :text, 'All Text')
      non_id_columns.each do |column|
        @facets << build_facet(column.name)
      end
    end
    
    def non_id_columns
      @model_class.columns.select { |c| c.name.to_s !~ /id$/ }
    end
    
    def column_name?(arg)
      @model_class.columns.map(&:name).map(&:to_s).include? arg.to_s
    end
  end
end
