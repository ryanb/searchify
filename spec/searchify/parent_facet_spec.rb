require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::ParentFacet do
  before(:each) do
    @facet = Searchify::ParentFacet.new(MockedModel, :all)
  end
  
  it "should have no children initially" do
    @facet.children.should be_empty
  end
  
  it "should be add a child facet" do
    child = Searchify::Facet.new(MockedModel, :name)
    @facet.add_child(child)
    @facet.children.should == [child]
  end
  
  it "should use child facets for conditions" do
    @facet.add_child Searchify::Facet.new(MockedModel, :name)
    @facet.conditions('Joe').should == ["mocked_models.name LIKE ?", 'Joe']
  end
  
  it "should join multiple child facet conditions" do
    @facet.add_child Searchify::Facet.new(MockedModel, :name)
    @facet.add_child Searchify::Facet.new(MockedModel, :foo)
    @facet.conditions('Joe').should == ["mocked_models.name LIKE ? AND mocked_models.foo LIKE ?", 'Joe', 'Joe']
  end
  
  it "should return nil for conditions if no children" do
    @facet.conditions('Joe').should be_nil
  end
  
  it "should only apply conditions to text facets" do
    @facet.add_child Searchify::Facet.new(MockedModel, :name, :text)
    @facet.add_child Searchify::Facet.new(MockedModel, :count, :integer)
    @facet.conditions('Joe').should == ["mocked_models.name LIKE ?", 'Joe']
  end
end
