require 'spec_helper'
module Yargi
  describe Digraph do
    
    it "should support creating a graph smootlhy" do
      d = Digraph.new{|d| d.add_vertex(:hello => "world")}
      d.vertices.size.should == 1
    end
    
  end
end