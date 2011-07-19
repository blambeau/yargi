require 'spec_helper'
module Yargi
  describe Digraph do
    
    it "should support creating a graph smootlhy" do
      d = Digraph.new{|d| d.add_vertex(:hello => "world")}
      d.vertices.size.should eq(1)
    end
    
    it "should allow connecting trough indexes" do
      v0, v1, edge = nil, nil, nil
      d = Digraph.new{|d| 
        v0, v1 = d.add_n_vertices(2) 
        edge = d.connect(v0,v1)
      }
      edge.source.should eq(v0)
      edge.target.should eq(v1)
    end
    
    it "should have a ith_vertex and ith_edge methods" do
      d = Digraph.new{|d| d.add_n_vertices(2); d.connect(0,1)}
      d.ith_vertex(0).index.should eq(0)
      d.ith_vertex(1).index.should eq(1)
      d.ith_edge(0).index.should eq(0)
    end
    
    it "should accept integers as vertices selectors" do
      d = Digraph.new{|d| d.add_n_vertices(2); d.connect(0,1)}
      d.vertices(1).collect{|v| v.index}.should eq([1])
    end
    
  end
end