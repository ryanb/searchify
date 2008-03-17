require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::Searcher do
  after(:each) do
    MockedModel.reset_columns
  end
  
  it "should not alter the options hash that is being passed in" do
    MockedModel.add_column(:name)
    searcher = Searchify::Searcher.new(MockedModel, :name)
    options = { :foo => 'bar' }
    searcher.search(options)
    options.should == { :foo => 'bar' }
  end
  
  it "should included specified association in search" do
    MockedModel.add_column(:name)
    MockedModel.has_many(:mocked_models)
    searcher = Searchify::Searcher.new(MockedModel, :mocked_models => [:name])
    searcher.search(:mocked_models_name => 'Joe')
    MockedModel.paginate_options[:include].should == [:mocked_models]
  end
end
