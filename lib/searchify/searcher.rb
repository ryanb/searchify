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
          conditions << facet_with_name(:all).conditions(value)
        else
          conditions << facet_with_name(name).conditions(value) unless facet_with_name(name).nil?
        end
      end
      ConditionsMerger.merge(conditions)
    end
    
    private
    
    def build_facet(*args)
      returning Facet.new(@model_class, *args) do |facet|
        facet_with_name(:all).add_child(facet) unless facet_with_name(:all).nil?
      end
    end
    
    def build_facets(args)
      args.each do |arg|
        if arg.to_sym == :all
          build_all_facets
        elsif column_name?(arg)
          @facets << build_facet(arg)
        elsif association_name?(arg)
          build_association_facets(arg)
        else
          raise "Argument '#{arg}' does not match any column or association for the model"
        end
      end
    end
    
    def build_all_facets
      @facets << ParentFacet.new(@model_class, :all, :text, 'All Text')
      non_id_columns.each do |column|
        @facets << build_facet(column.name)
      end
    end
    
    def build_association_facets(association_name)
      reflection = @model_class.reflect_on_association(association_name)
      reflection.klass.columns.each do |column|
        @facets << Facet.new(@model_class, [association_name, column.name].join('_'))
      end
    end
    
    def facet_with_name(name)
      @facets.detect { |f| f.name == name.to_s }
    end
    
    def non_id_columns
      @model_class.columns.select { |c| c.name.to_s != 'id' && c.name.to_s !~ /_id$/ }
    end
    
    def column_name?(arg)
      @model_class.columns.map(&:name).map(&:to_s).include? arg.to_s
    end
    
    def association_name?(arg)
      @model_class.reflect_on_association(arg)
    end
  end
end
