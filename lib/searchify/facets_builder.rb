module Searchify
  class FacetsBuilder
    def self.build(model_class, arguments, prefix = nil)
      FacetsBuilder.new(model_class, arguments, prefix).build
    end
    
    def initialize(model_class, arguments, prefix = nil)
      @model_class = model_class
      @arguments = arguments
      @prefix = prefix
    end
    
    def build
      facet_names.map do |name|
        facets_for_name(name)
      end.flatten
    end
    
    def facets_for_name(name)
      if name.to_sym == :all
        build_all_facets
      elsif column_name?(name)
        build_facet(name, :text, nil, @prefix)
      elsif association_name?(name)
        build_association_facets(name)
      else
        raise "Argument '#{name}' does not match any column or association for the model"
      end
    end
    
    private
    
    def facet_names
      @arguments # I'll need to expand this once I start accepting hash options
    end
    
    def build_facet(*options)
      returning Facet.new(@model_class, *options) do |facet|
        @parent_facet.add_child(facet) if @parent_facet
      end
    end
    
    def build_all_facets
      @parent_facet = ParentFacet.new(@model_class, :all, :text, 'All Text') if @prefix.blank?
      ([@parent_facet] + non_id_columns.map { |column| build_facet(column.name, :text, nil, @prefix) }).compact
    end
    
    def build_association_facets(association_name)
      reflection = @model_class.reflect_on_association(association_name)
      reflection.klass.columns.map do |column|
        Facet.new(@model_class, [association_name, column.name].join('_'))
      end
    end
    
    def non_id_columns
      @model_class.columns.select { |c| c.name.to_s != 'id' && c.name.to_s !~ /_id$/ }
    end
    
    def column_name?(name)
      @model_class.columns.map(&:name).map(&:to_s).include? name.to_s
    end
    
    def association_name?(name)
      @model_class.reflect_on_association(name)
    end
  end
end
