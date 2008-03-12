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
end
