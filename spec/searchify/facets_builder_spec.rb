require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::FacetsBuilder do
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should include a facet for each model column specified and 'all'" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:ignore_me)
    facets = Searchify::FacetsBuilder.build(MockedModel, [:name])
    facets.map(&:key_name).should == %w[all name]
  end
  
  it "should raise an error if attempting to build a facet which isn't a column" do
    MockedModel.add_column(:name)
    lambda {
      searcher = Searchify::FacetsBuilder.build(MockedModel, [:foo])
    }.should raise_error(Exception)
  end
  
  it "should have a display name of 'All Text' and type 'text' for 'all' facet" do
    facets = Searchify::FacetsBuilder.build(MockedModel, [])
    facets.first.display_name.should == 'All Text'
    facets.first.type.should == :text
  end
  
  it "should pass along prefix to facets" do
    MockedModel.add_column(:name)
    facets = Searchify::FacetsBuilder.build(MockedModel, [:name], :foo)
    facets.map(&:key_name).should == %w[foo_name]
  end
  
  it "should be able to specify columns to use in the association" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    MockedModel.has_many(:mocked_models)
    facets = Searchify::FacetsBuilder.build(MockedModel, [{:mocked_models => [:name]}])
    facets.map(&:key_name).should == %w[all mocked_models_name]
  end
  
  it "should include association facets as children in the 'all' facet" do
    MockedModel.add_column(:name)
    MockedModel.has_many(:mocked_models)
    facets = Searchify::FacetsBuilder.build(MockedModel, [{:mocked_models => [:name]}])
    facets.first.children.map(&:key_name).should == %w[mocked_models_name]
  end
  
  it "should maintain column type in facet" do
    MockedModel.add_column(:created_at, :datetime)
    facets = Searchify::FacetsBuilder.build(MockedModel, [:created_at])
    facet = facets.detect { |f| f.name == 'created_at' }
    facet.type.should == :datetime
  end
end
