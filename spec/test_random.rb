require 'spec_helper'
module Yargi
  describe Random do
    
    it "should be installed as a graph class method" do
      Digraph.random.should be_a(Digraph)
    end
    
    it "should serve the requested number of vertices unless strip" do
      graph = Digraph.random do |r|
         r.vertex_count = 10
         r.edge_count = 20
         r.strip = false
      end
      graph.vertex_count.should == 10
      graph.edge_count.should == 20
    end
    
    it "should allow specifying sizes inline" do
      graph = Digraph.random(10, 20) do |r|
         r.strip = false
      end
      graph.vertex_count.should == 10
      graph.edge_count.should == 20
    end
    
    it "should strip the graph if requested" do
      graph = Digraph.random(50, 20)
      graph.vertex_count.should_not eq(50)
      Decorate::DEPTH.execute(graph)
      graph.vertices{|v| v[:depth] > 20}.should be_empty
    end
    
    it "should allow specifying vertex and edge builders" do
      graph = Digraph.random(10, 20) do |r|
        r.vertex_builder = lambda{|v,i| v[:i] = i}
        r.edge_builder   = lambda{|e,i| e[:i] = i}
        r.strip = false
      end
      graph.vertices.collect{|v| v[:i]}.should == (0...10).to_a
      graph.edges.collect{|e| e[:i]}.should == (0...20).to_a
    end
    
  end
end