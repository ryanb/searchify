require 'rubygems'
require 'spec'
require 'active_support'
require 'action_pack'
require 'active_record'
require File.dirname(__FILE__) + '/../lib/searchify.rb'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

class MockedModel < ActiveRecord::Base
  class_inheritable_hash :paginate_options
  
  def self.paginate(options)
    self.paginate_options = options
  end
  
  def self.add_column(name, type = :string)
    returning ActiveRecord::ConnectionAdapters::Column.new(name, nil) do |column|
      column.stubs(:type).returns(type)
      @columns ||= []
      @columns << column
    end
  end
  
  def self.reset_columns
    @columns = []
  end
  
  def self.columns
    @columns || []
  end
  
  def self.inspect
    "Model Mock"
  end
  
  def self.table_name
    'mocked_models'
  end
end
