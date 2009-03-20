$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'yargi'

module DirVertex; end
module FileVertex; end

# Recursively create vertices and edges in the graph
def build_graph(dir, graph, parent)
  subnodes = Dir["#{dir}/*"].collect do |f|
    is_dir = File.directory?(f)
    vertex = graph.add_vertex(is_dir ? DirVertex : FileVertex, {:file => f})
    build_graph(f, graph, vertex) if is_dir
    vertex
  end
  graph.connect(parent, subnodes)
end

# Starts the creation
dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
graph = Yargi::Digraph.new
root = graph.add_vertex(DirVertex, {:file => dir})
build_graph(dir, graph, root)

# Add dot attributes
graph.add_marks(:rankdir => 'LR')
graph.vertices.add_marks(:shape => :box, 
                         :style => 'filled', 
                         :width => 1.5, 
                         :height => 0.3, 
                         :fixedsize => true) do |v,i| 
  {:label => File.basename(v.file)}
end
graph.vertices(DirVertex).add_marks(:fillcolor => 'yellow')
graph.vertices(FileVertex).add_marks(:fillcolor => 'green')

# Save it
File.open(File.join(File.dirname(__FILE__), 'fs2dot.dot'), 'w') do |f|
  f << graph.to_dot
end