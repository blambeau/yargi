require 'spec_helper'
module Yargi
  describe Digraph do
    
    let(:graph) do
      Digraph.new{|g|
        v0, v1 = g.add_n_vertices(2) 
        g.connect(v0,v1)
      }
    end
    
    it "should support creating a graph smootlhy" do
      graph.should be_a(Digraph)
    end
    
    it "should have vertex_count and edge_count methods" do
      graph.vertex_count.should eq(2)
      graph.edge_count.should eq(1)
    end
    
    it "should allow connecting trough indexes" do
      v0, v1, edge = nil, nil, nil
      d = Digraph.new{|d| 
        v0, v1 = d.add_n_vertices(2) 
        edge = d.connect(0,1).first
      }
      edge.source.should eq(v0)
      edge.target.should eq(v1)
    end
    
    it "should have a ith_vertex and ith_edge methods" do
      graph.ith_vertex(0).index.should eq(0)
      graph.ith_vertex(1).index.should eq(1)
      graph.ith_edge(0).index.should eq(0)
    end
    
    it "should accept integers as vertices selectors" do
      graph.vertices(1).collect{|v| v.index}.should eq([1])
    end
    
  end
end