require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::FacetsBuilder do
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should include a facet for each model column specified" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:ignore_me)
    facets = Searchify::FacetsBuilder.build(MockedModel, :name)
    facets.should have(1).record
    facets.first.name.should == 'name'
  end
  
  it "should raise an error if attempting to build a facet which isn't a column" do
    MockedModel.add_column(:name)
    lambda {
      searcher = Searchify::FacetsBuilder.build(MockedModel, :foo)
    }.should raise_error(Exception)
  end
  
  it "should include all columns with 'all' facet" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:created_at)
    facets = Searchify::FacetsBuilder.build(MockedModel, :all)
    facets.should have(3).records
    facets.first.name.should == 'all'
  end
  
  it "should include ignore columns ending in 'id' with 'all' facet" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:id)
    MockedModel.add_column(:parent_id)
    facets = Searchify::FacetsBuilder.build(MockedModel, :all)
    facets.should have(2).records
    facets.first.name.should == 'all'
    facets.last.name.should == 'name'
  end
  
  it "should have a display name of 'All Text' and type 'text' for 'all' facet" do
    facets = Searchify::FacetsBuilder.build(MockedModel, :all)
    facets.first.display_name.should == 'All Text'
    facets.first.type.should == :text
  end
  
  it "should include a facet through associations" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    MockedModel.has_many(:mocked_models)
    facets = Searchify::FacetsBuilder.build(MockedModel, :mocked_models)
    facets.map(&:name).should == %w[mocked_models_name mocked_models_foo]
  end
end
