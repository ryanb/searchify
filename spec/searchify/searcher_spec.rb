require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::Searcher do
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should be able to have no conditions" do
    searcher = Searchify::Searcher.new(MockedModel)
    searcher.conditions({}).should be_nil
  end
  
  it "should have conditions for searching name" do
    MockedModel.add_column(:name)
    searcher = Searchify::Searcher.new(MockedModel, :name)
    searcher.conditions(:name => 'Joe').should == ["(mocked_models.name LIKE ?)", 'Joe']
  end
  
  it "should have conditions for searching all columns" do
    MockedModel.add_column(:name)
    searcher = Searchify::Searcher.new(MockedModel, :name)
    searcher.conditions(:name => 'Joe').should == ["(mocked_models.name LIKE ?)", 'Joe']
  end
  
  # it's difficult to test this all in one expectation because the order of the conditions can change
  it "should be able to have multiple conditions" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    searcher = Searchify::Searcher.new(MockedModel, :name, :foo)
    conditions = searcher.conditions(:name => 'Joe', :foo => 'Bar')
    conditions.first.should include("(mocked_models.name LIKE ?)")
    conditions.first.should include("(mocked_models.foo LIKE ?)")
    conditions.first.should include("AND")
    conditions.should include("Joe")
    conditions.should include("Bar")
  end
  
  it "should have association conditions" do
    MockedModel.add_column(:name)
    MockedModel.has_many(:mocked_models)
    searcher = Searchify::Searcher.new(MockedModel, :mocked_models => [:name])
    searcher.conditions(:mocked_models_name => 'Joe').should == ["(mocked_models.name LIKE ?)", 'Joe']
  end
  
  it "should have conditions for all columns" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    searcher = Searchify::Searcher.new(MockedModel, :name, :foo)
    searcher.conditions(:all => 'Joe').should == ["((mocked_models.name LIKE ?) OR (mocked_models.foo LIKE ?))", 'Joe', 'Joe']
  end
  
  it "should have conditions for all columns and another" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    searcher = Searchify::Searcher.new(MockedModel, :name, :foo)
    conditions = searcher.conditions(:all => 'Joe', :name => 'Jo%')
    conditions.first.should include("(mocked_models.name LIKE ?) OR (mocked_models.foo LIKE ?)")
    conditions.first.should include("(mocked_models.name LIKE ?)")
    conditions.first.should include("AND")
    conditions.should include("Joe")
    conditions.should include("Jo%")
  end
end
