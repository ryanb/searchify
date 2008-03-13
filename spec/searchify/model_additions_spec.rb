require File.dirname(__FILE__) + '/../spec_helper'

describe MockedModel do
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should be able to add a column" do
    MockedModel.add_column('foo')
    MockedModel.columns.should have(1).record
    MockedModel.columns.first.name.should == 'foo'
  end
  
  it "should pass search column as a LIKE condition" do
    MockedModel.add_column(:name)
    MockedModel.searchify(:name)
    MockedModel.search(:name => 'Ryan')
    MockedModel.paginate_options[:conditions].should == ["(mocked_models.name LIKE ?)", 'Ryan']
  end
  
  it "should return facets when calling searchify_facets on model" do
    MockedModel.add_column(:name)
    MockedModel.add_column(:foo)
    MockedModel.searchify(:name, :foo)
    MockedModel.searchify_facets.map(&:key_name).should == %w[all name foo]
  end
end

describe MockedModel, "with searchify" do
  before(:each) do
    MockedModel.searchify
  end
  
  it "should add a search method to model" do
    MockedModel.should respond_to(:search)
  end
  
  it "should call paginate on model when calling search" do
    MockedModel.expects(:paginate)
    MockedModel.search
  end
  
  it "should pass per_page option" do
    MockedModel.search(:per_page => 10)
    MockedModel.paginate_options[:per_page].should == 10
  end
  
  it "should pass page = 1 if page not specified" do
    MockedModel.search
    MockedModel.paginate_options[:page].should == 1
  end
  
  it "should pass page option" do
    MockedModel.search(:page => 3)
    MockedModel.paginate_options[:page].should == 3
  end
  
  it "should ignore unknown options" do
    MockedModel.search(:foobiedo => 'should ignore')
    MockedModel.paginate_options[:foobiedo].should be_nil
  end
  
  it "should have a searcher" do
    MockedModel.searcher.should_not be_nil
  end
end
