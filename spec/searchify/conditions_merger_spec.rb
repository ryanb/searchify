require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::ConditionsMerger do
  it "should flatten simple conditions" do
    Searchify::ConditionsMerger.merge([["foo=?", 'bar']]).should == ['(foo=?)', 'bar']
  end
  
  it "should return nil if conditions are nil" do
    Searchify::ConditionsMerger.merge([nil]).should be_nil
  end
  
  it "should join multiple conditions" do
    Searchify::ConditionsMerger.merge([['a', 1], ['b', 2]]).should == ['(a) AND (b)', 1, 2]
  end
  
  it "should merge different size arrays" do
    Searchify::ConditionsMerger.merge([['a', 1, 2], ['b', 3]]).should == ['(a) AND (b)', 1, 2, 3]
  end
  
  it "should properly merge mixed values" do
    Searchify::ConditionsMerger.merge([['a', 1], 'b', nil]).should == ['(a) AND (b)', 1]
  end
  
  it "should be able to specify OR join" do
    Searchify::ConditionsMerger.merge(['a', 'b'], 'OR').should == ['(a) OR (b)']
  end
end
