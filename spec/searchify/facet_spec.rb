require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::Facet do
  it "should default display name of 'first_name' to 'First Name'" do
    facet = Searchify::Facet.new(MockedModel, :first_name)
    facet.display_name.should == 'First Name'
  end
  
  it "should be able to override display name" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, 'Name')
    facet.display_name.should == 'Name'
  end
  
  it "should use table name" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, 'Name')
    facet.display_name.should == 'Name'
  end
  
  it "should know if it's an 'all' facet" do
    Searchify::Facet.new(MockedModel, :first_name, :text, 'Name').should_not be_all
    Searchify::Facet.new(MockedModel, :all, :text, 'Name').should be_all
  end
  
  it "should have conditions for a given value" do
    facet = Searchify::Facet.new(MockedModel, :name)
    facet.conditions('foo').should == ["mocked_models.name LIKE ?", 'foo']
  end
  
  it "should default to text type" do
    Searchify::Facet.new(MockedModel, :name).type.should == :text
  end
end
