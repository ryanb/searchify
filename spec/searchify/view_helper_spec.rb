require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::ViewHelper, "template" do
  before(:each) do
    MockedModel.reset_columns
    MockedModel.add_column(:name)
    MockedModel.searchify(:name)
    @template = ActionView::Base.new
  end
  
  it "should have a blank searchify div for searchify_fields_for" do
    @template.searchify_fields_for(MockedModel).should include('<div id="searchify"></div>')
  end
  
  it "should include facets converted to json in searchify_fields_for" do
    @template.searchify_fields_for(MockedModel).should include(MockedModel.searchify_facets.to_json)
  end
  
  it "should include searchify javascript in searchify_fields_for" do
    @template.searchify_fields_for(MockedModel).should include("/javascripts/searchify.js")
  end
end
