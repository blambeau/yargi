require 'spec_helper'
describe Yargi do

  it "should have a version number" do
    Yargi.const_defined?(:VERSION).should be_true
  end

end
