require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::SearchOptions do
  before(:each) do
    MockedModel.reset_columns
  end
  
  def build_facets(*options)
    Searchify::FacetsBuilder.build(MockedModel, options)
  end
  
  it "should be able to have no conditions" do
    options = Searchify::SearchOptions.new([], {})
    options.conditions_option.should be_nil
  end
  
  it "should have conditions for searching name" do
    MockedModel.add_column(:name)
    options = Searchify::SearchOptions.new(build_facets(:name), :name => 'Joe')
    options.conditions_option.should == ["(mocked_models.name LIKE ?)", 'Joe']
  end
  
  it "should have conditions for searching all columns" do
    MockedModel.add_column(:name)
    options = Searchify::SearchOptions.new(build_facets(:name), :all => 'Joe')
    options.conditions_option.should == ["(((mocked_models.name LIKE ?)))", '%Joe%']
  end
  
  # it's difficult to test this all in one expectation because the order of the conditions can change
  it "should be able to have multiple conditions" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    options = Searchify::SearchOptions.new(build_facets(:name, :foo), :name => 'Joe', :foo => 'Bar')
    conditions = options.conditions_option
    conditions.first.should include("(mocked_models.name LIKE ?)")
    conditions.first.should include("(mocked_models.foo LIKE ?)")
    conditions.first.should include("AND")
    conditions.should include("Joe")
    conditions.should include("Bar")
  end
  
  it "should have association conditions" do
    MockedModel.add_column(:name)
    MockedModel.has_many(:mocked_models)
    options = Searchify::SearchOptions.new(build_facets(:mocked_models => [:name]), :mocked_models_name => 'Joe')
    options.conditions_option.should == ["(mocked_models.name LIKE ?)", 'Joe']
  end
  
  it "should have conditions for all columns" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    options = Searchify::SearchOptions.new(build_facets(:name, :foo), :all => 'Joe')
    options.conditions_option.should == ["(((mocked_models.name LIKE ?) OR (mocked_models.foo LIKE ?)))", '%Joe%', '%Joe%']
  end
  
  it "should have conditions for all columns and another" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    options = Searchify::SearchOptions.new(build_facets(:name, :foo), :all => 'Joe', :name => 'Jo%')
    conditions = options.conditions_option
    conditions.first.should include("(mocked_models.name LIKE ?) OR (mocked_models.foo LIKE ?)")
    conditions.first.should include("(mocked_models.name LIKE ?)")
    conditions.first.should include("AND")
    conditions.should include("%Joe%")
    conditions.should include("Jo%")
  end
  
  it "should include association facets in conditions when searching all columns" do
    MockedModel.add_column(:name)
    MockedModel.has_many(:mocked_models)
    options = Searchify::SearchOptions.new(build_facets(:mocked_models => [:name]), :all => 'Joe')
    options.conditions_option.should == ["(((mocked_models.name LIKE ?)))", '%Joe%']
  end
  
  it "should include order option" do
    MockedModel.add_column(:name)
    MockedModel.has_many(:mocked_models)
    options = Searchify::SearchOptions.new(build_facets(:mocked_models => [:name]), 'order' => 'mocked_models_name')
    options.for_paginate[:order].should == 'mocked_models.name'
  end
end
