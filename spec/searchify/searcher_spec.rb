require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::Searcher do
  after(:each) do
    ModelMock.reset_columns
  end
  
  it "should include a facet for each model column specified" do
    ModelMock.add_column(:name)
    ModelMock.add_column(:ignore_me)
    searcher = Searchify::Searcher.new(ModelMock, :name)
    searcher.facets.should have(1).record
    searcher.facets.first.name.should == 'name'
  end
  
  it "should raise an error if attempting to include a facet which isn't a column" do
    ModelMock.add_column(:name)
    lambda {
      searcher = Searchify::Searcher.new(ModelMock, :foo)
    }.should raise_error(Exception)
  end
  
  it "should include all columns with 'all' facet" do
    ModelMock.add_column(:name)
    ModelMock.add_column(:created_at)
    searcher = Searchify::Searcher.new(ModelMock, :all)
    searcher.facets.should have(3).records
    searcher.facets.first.name.should == 'all'
  end
  
  it "should include ignore columns ending in 'id' with 'all' facet" do
    ModelMock.add_column(:name)
    ModelMock.add_column(:id)
    ModelMock.add_column(:parent_id)
    searcher = Searchify::Searcher.new(ModelMock, :all)
    searcher.facets.should have(2).records
    searcher.facets.first.name.should == 'all'
    searcher.facets.last.name.should == 'name'
  end
  
  it "should have a display name of 'All Text' and type 'text' for 'all' facet" do
    searcher = Searchify::Searcher.new(ModelMock, :all)
    searcher.facets.first.display_name.should == 'All Text'
    searcher.facets.first.type.should == :text
  end
  
  it "should be able to have no conditions" do
    searcher = Searchify::Searcher.new(ModelMock, :all)
    searcher.conditions({}).should be_nil
  end
  
  it "should have conditions for searching name" do
    ModelMock.add_column(:name)
    searcher = Searchify::Searcher.new(ModelMock, :name)
    searcher.conditions(:name => 'Joe').should == ["model_mocks.name LIKE ?", 'Joe']
  end
  
  # it's difficult to test this all in one expectation because the order of the conditions can change
  it "should be able to have multiple conditions" do
    ModelMock.add_column(:name)
    ModelMock.add_column(:foo)
    searcher = Searchify::Searcher.new(ModelMock, :name)
    conditions = searcher.conditions(:name => 'Joe', :foo => 'Bar')
    conditions.first.should include("model_mocks.name LIKE ?")
    conditions.first.should include("model_mocks.foo LIKE ?")
    conditions.should include("Joe")
    conditions.should include("Bar")
  end
  
  it "should have conditions for all columns" do
    ModelMock.add_column(:name)
    ModelMock.add_column(:foo)
    searcher = Searchify::Searcher.new(ModelMock, :all)
    searcher.conditions(:all => 'Joe').should == ["model_mocks.name LIKE ? AND model_mocks.foo LIKE ?", 'Joe', 'Joe']
  end
  
  it "should have conditions for all columns except those ending in id" do
    ModelMock.add_column(:name)
    ModelMock.add_column(:id)
    ModelMock.add_column(:parent_id)
    searcher = Searchify::Searcher.new(ModelMock, :all)
    searcher.conditions(:all => 'Joe').should == ["model_mocks.name LIKE ?", 'Joe']
  end
end
