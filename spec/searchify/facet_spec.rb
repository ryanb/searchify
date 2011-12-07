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
    facet.to_json.should == { :name => 'foo_first_name', :display => 'Name', :type => 'text' }.to_json
  end
  
  it "should be able to accept options for json" do
    facet = Searchify::Facet.new(MockedModel, :first_name, :text, 'Name', :foo)
    facet.to_json(:only => [:name]).should == { :name => 'foo_first_name' }.to_json
  end
  
  it "should have conditions for raw options" do
    facet = Searchify::Facet.new(MockedModel, :count, :integer, nil, :foo)
    raw_options = { :foo_count => '5', :foo_count_operator => '>=', :ignore_this => 'ignore' }
    facet.conditions_for_raw_options(raw_options).should == ["mocked_models.count >= ?", '5']
  end
  
  it "should surround value with percent signs when doing 'contains' condition" do
    facet = Searchify::Facet.new(MockedModel, :name)
    facet.conditions(:contains => 'Joe').should == ["mocked_models.name LIKE ?", '%Joe%']
  end
end

describe Searchify::Facet, "with integer column" do
  before(:each) do
    @facet = Searchify::Facet.new(MockedModel, :count, :integer)
  end
  
  it "should be able to provide the operator for conditions" do
    @facet.conditions(:operator => '<=', :value => '5').should == ["mocked_models.count <= ?", '5']
  end
  
  it "should fall back to LIKE condition if operator is invalid" do
    @facet.conditions(:operator => 'foo', :value => '5').should == ["mocked_models.count LIKE ?", '5']
  end
  
  %w[< > <= >= = != <>].each do |operator|
    it "should support #{operator} as a condition operator" do
      @facet.conditions(:operator => operator, :value => '5').should == ["mocked_models.count #{operator} ?", '5']
    end
  end
end

describe Searchify::Facet, "with date column" do
  before(:each) do
    @facet = Searchify::Facet.new(MockedModel, :created_at, :date)
  end
  
  it "should support passing 'from' and 'to' date range" do
    @facet.conditions(:from => '2008-01-01', :to => '2008-02-01').should == ["mocked_models.created_at >= ? AND mocked_models.created_at <= ?", '2008-01-01', '2008-02-01']
  end
  
  it "should have no conditions when passing blank for both from and to date range" do
    @facet.conditions(:from => '', :to => '').should be_nil
  end
  
  it "should have only 'from' condition if 'to' is blank" do
    @facet.conditions(:from => '2008-01-01', :to => '').should == ["mocked_models.created_at >= ?", '2008-01-01']
  end
  
  it "should have only 'to' condition if 'from' is blank" do
    @facet.conditions(:from => '', :to => '2008-01-01').should == ["mocked_models.created_at <= ?", '2008-01-01']
  end
end
