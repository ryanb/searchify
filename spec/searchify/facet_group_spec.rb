require File.dirname(__FILE__) + '/../spec_helper'

describe Searchify::FacetGroup do
  it "should default display name of 'first_name' to 'First Name'" do
    facet = Searchify::FacetGroup.new(ModelMock, :first_name)
    facet.display_name.should == 'First Name'
  end
end
