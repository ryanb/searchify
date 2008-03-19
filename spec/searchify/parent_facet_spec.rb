require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::ParentFacet do
  before(:each) do
    @facet = Searchify::ParentFacet.new(MockedModel, :all)
  end
  
  it "should have no children initially" do
    @facet.children.should be_empty
  end
  
  it "should be able to add a child facet" do
    child = Searchify::Facet.new(MockedModel, :name)
    @facet.add_child(child)
    @facet.children.should == [child]
  end
  
  it "should be able to add multiple children" do
    child = Searchify::Facet.new(MockedModel, :name)
    @facet.add_children([child, child])
    @facet.children.should == [child, child]
  end
  
  it "should return nil for conditions if no children" do
    @facet.conditions(:value => 'Joe').should be_nil
  end
  
  it "should behave like a full text search and split the string by spaces and see if they match any children facets" do
    @facet.add_child Searchify::Facet.new(MockedModel, :first_name)
    @facet.add_child Searchify::Facet.new(MockedModel, :last_name)
    @facet.conditions(:value => 'John Smith').should == ["((mocked_models.first_name LIKE ?) OR (mocked_models.last_name LIKE ?)) AND ((mocked_models.first_name LIKE ?) OR (mocked_models.last_name LIKE ?))", '%John%', '%John%', '%Smith%', '%Smith%']
  end
  
  it "should return nil for conditions if no options" do
    @facet.conditions({}).should be_nil
  end
end
