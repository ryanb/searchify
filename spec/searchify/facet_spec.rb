require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::Facet do
  it "should default display name of 'first_name' to 'First Name'" do
    facet = Searchify::Facet.new(ModelMock, :first_name)
    facet.display_name.should == 'First Name'
  end
  
  it "should be able to override display name" do
    facet = Searchify::Facet.new(ModelMock, :first_name, :text, 'Name')
    facet.display_name.should == 'Name'
  end
  
  it "should use table name" do
    facet = Searchify::Facet.new(ModelMock, :first_name, :text, 'Name')
    facet.display_name.should == 'Name'
  end
  
  it "should know if it's an 'all' facet" do
    Searchify::Facet.new(ModelMock, :first_name, :text, 'Name').should_not be_all
    Searchify::Facet.new(ModelMock, :all, :text, 'Name').should be_all
  end
  
  it "should have conditions for a given value" do
    facet = Searchify::Facet.new(ModelMock, :name)
    facet.conditions('foo').should == ["model_mocks.name LIKE ?", 'foo']
  end
end
