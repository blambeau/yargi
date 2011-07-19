require 'spec_helper'
module Yargi
  describe Decorate do
    
    let(:graph) do
      graph = Digraph.new{|d|
        v0, v1, v2, v3 = d.add_n_vertices(4)
        d.connect(v0, v1)
        d.connect(v1, v2)
        d.connect(v2, v3)
        d.connect(v0, v3)
      }
    end
    
    specify "DEPTH" do
      Decorate::DEPTH.execute(graph, [graph.vertices.first])
      graph.vertices.collect{|v| v[:depth]}.should == [0, 1, 2, 1]
    end
    
    specify "SHORTEST_PATH" do
      Decorate::SHORTEST_PATH.execute(graph, [graph.vertices.first])
      graph.vertices.collect{|v| v[:shortest_path].join(',')}.should == [
        "", "e0:V0->V1", "e0:V0->V1,e1:V1->V2", "e3:V0->V3"
      ]
    end
  
  end
end