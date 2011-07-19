$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'yargi'

COLORS = ["blue", "red", "yellow", "green"]

# We build a random graph with approximately 20 vertices
# and 60 edges (will be stripped by default). Each vertex
# will have a color picked at random. 
graph = Yargi::Digraph.random(20,60) do |r|
  r.vertex_builder = lambda{|v,i|
    v[:color] = COLORS[Kernel.rand(COLORS.size)]
  }
end

# The label of each vertex will be its depth
Yargi::Decorate::DEPTH.execute(graph)
graph.vertices.add_marks{|v| {:label => v[:depth]}}
  
# Print as a dot graph
puts graph.to_dot