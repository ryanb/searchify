require File.dirname(__FILE__) + '/../spec_helper'

describe ModelMock, "with searchify" do
  before(:each) do
    ModelMock.searchify
  end
  
  after(:each) do
    ModelMock.reset_columns
  end
  
  it "should add a search method to model" do
    ModelMock.should respond_to(:search)
  end
  
  it "should call paginate on model when calling search" do
    ModelMock.expects(:paginate)
    ModelMock.search
  end
  
  it "should pass per_page option" do
    ModelMock.search(:per_page => 10)
    ModelMock.paginate_options[:per_page].should == 10
  end
  
  it "should pass page = 1 if page not specified" do
    ModelMock.search
    ModelMock.paginate_options[:page].should == 1
  end
  
  it "should pass page option" do
    ModelMock.search(:page => 3)
    ModelMock.paginate_options[:page].should == 3
  end
  
  it "should ignore unknown options" do
    ModelMock.search(:foobiedo => 'should ignore')
    ModelMock.paginate_options[:foobiedo].should be_nil
  end
  
  it "should be able to add a column" do
    ModelMock.add_column('foo')
    ModelMock.columns.should have(1).record
    ModelMock.columns.first.name.should == 'foo'
  end
  
  it "should pass search column as a LIKE condition" do
    ModelMock.add_column(:name)
    ModelMock.search(:name => 'Ryan')
    ModelMock.paginate_options[:conditions].should == ["model_mocks.name LIKE ?", 'Ryan']
  end
  
  it "should have a searcher" do
    ModelMock.searcher.should_not be_nil
  end
end
