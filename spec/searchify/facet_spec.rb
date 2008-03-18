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
  
  it "should know if it's an 'all' facet" do
    Searchify::Facet.new(MockedModel, :first_name, :text, 'Name').should_not be_all
    Searchify::Facet.new(MockedModel, :all, :text, 'Name').should be_all
  end
  
  it "should have conditions for a given value" do
    facet = Searchify::Facet.new(MockedModel, :name)
    facet.conditions(:value => 'foo').should == ["mocked_models.name LIKE ?", 'foo']
  end
  
  it "should ask model for table name" do
    MockedModel.stubs(:table_name).returns('custom_table')
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, 'Name')
    facet.conditions(:value => 'Joe').should == ["custom_table.first_name LIKE ?", 'Joe']
  end
  
  it "should default to text type" do
    Searchify::Facet.new(MockedModel, :name).type.should == :text
  end
  
  it "should include passed prefix in key name" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, nil, :foo)
    facet.key_name.should == 'foo_first_name'
  end
  
  it "should default key name to only name when no prefixed passed" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, nil)
    facet.key_name.should == 'first_name'
  end
  
  it "should be able to export to json" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, 'Name', :foo)
    facet.to_json.should == { :name => 'foo_first_name', :display => 'Name', :type => 'text', :default_value => '' }.to_json
  end
  
  it "should be able to accept options for json" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, 'Name', :foo)
    facet.to_json(:only => [:name]).should == { :name => 'foo_first_name' }.to_json
  end
  
  it "should be able to provide the operator" do
    facet = Searchify::Facet.new(MockedModel, :count, :integer)
    facet.conditions(:operator => '<=', :value => '5').should == ["mocked_models.count <= ?", '5']
  end
  
  it "should fall back to LIKE condition if operator is invalid" do
    facet = Searchify::Facet.new(MockedModel, :count, :integer)
    facet.conditions(:operator => 'foo', :value => '5').should == ["mocked_models.count LIKE ?", '5']
  end
  
  %w[< > <= >= = != <>].each do |operator|
    it "should support #{operator} as an operator" do
      facet = Searchify::Facet.new(MockedModel, :count, :integer)
      facet.conditions(:operator => operator, :value => '5').should == ["mocked_models.count #{operator} ?", '5']
    end
  end
end
