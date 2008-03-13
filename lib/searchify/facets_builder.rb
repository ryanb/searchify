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
      facets = []
      facets << build_all_facet if @prefix.blank?
      facets += facet_names.map { |name| facets_for_name(name) }.flatten
      facets
    end
    
    def facets_for_name(name)
      if column_name?(name)
        build_facet(name, :text, nil, @prefix)
      elsif association_name?(name)
        build_association_facets(name)
      else
        raise "Argument '#{name}' does not match any column or association for the model"
      end
    end
    
    private
    
    def facet_names
      @arguments.map do |arg|
        if arg.kind_of? Hash
          arg.keys
        else
          arg
        end
      end.flatten
    end
    
    def build_facet(*options)
      returning Facet.new(@model_class, *options) do |facet|
        @parent_facet.add_child(facet) if @parent_facet
      end
    end
    
    def build_all_facet
      @parent_facet = ParentFacet.new(@model_class, :all, :text, 'All Text')
    end
    
    def build_association_facets(association_name)
      reflection = @model_class.reflect_on_association(association_name)
      FacetsBuilder.build(reflection.klass, arguments_for_association(association_name), association_name)
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
    
    def arguments_for_association(name)
      association_hash[name]
    end
    
    def association_hash
      @arguments.last.kind_of?(Hash) ? @arguments.last : {}
    end
  end
end
