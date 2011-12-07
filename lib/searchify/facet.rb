module Searchify
  class Facet
    attr_accessor :model_class, :name, :display_name, :type
    
    def initialize(model_class, name, type = :text, display_name = nil, prefix = nil)
      @name = name.to_s
      @display_name = display_name
      @type = type
      @model_class = model_class
      @prefix = prefix
    end
    
    def display_name
      @display_name || name.titleize
    end
    
    def key_name
      [@prefix, @name].compact.join('_')
    end
    
    def all?
      @name == 'all'
    end
    
    def conditions(options)
      if options[:from] || options[:to]
        if !options[:from].blank? && !options[:to].blank?
          ["#{column_name} >= ? AND #{column_name} <= ?", options[:from], options[:to]]
        elsif !options[:from].blank?
          ["#{column_name} >= ?", options[:from]]
        elsif !options[:to].blank?
          ["#{column_name} <= ?", options[:to]]
        end
      elsif options[:operator] && valid_operator?(options[:operator])
        ["#{column_name} #{options[:operator]} ?", options[:value]]
      elsif options[:contains]
        ["#{column_name} LIKE ?", "%#{options[:contains]}%"]
      elsif options[:value]
        ["#{column_name} LIKE ?", options[:value]]
      end
    end
    
    def column_name
      "#{@model_class.table_name}.#{name}"
    end
    
    def to_json(options = {})
      { :name => key_name, :display => display_name, :type => type }.to_json(options)
    end
    
    def conditions_for_raw_options(raw_options)
      conditions(condition_options_from_raw_options(raw_options))
    end
    
    private
    
    def condition_options_from_raw_options(raw_options)
      options = {}
      raw_options.each do |name, value|
        if name.to_s == key_name
          options[:value] = value
        elsif name.to_s.starts_with? "#{key_name}_"
          options[name.to_s.sub("#{key_name}_", '').to_sym] = value
        end
      end
      options
    end
    
    def valid_operator?(operator)
      %w[< > <= >= = != <>].include? operator
    end
  end
end
