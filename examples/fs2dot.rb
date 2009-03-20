$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'yargi'

module DirVertex; end
module FileVertex; end

# Recursively create vertices and edges in the graph
def build_graph(dir, graph, parent)
  return if /test|doc$/ =~ dir
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
graph.vertices.add_marks(
  :shape => :box, :width => 1.6, :height => 0.4,
  :fontname => 'Arial', :fontsize => '16'
)

graph.vertices(DirVertex).add_marks(:shape => 'folder', :style => "filled", :fillcolor => 'cornsilk2') do |v|
  {:label => "#{File.basename(v.file)}"}
end
graph.vertices(DirVertex){|v| v.out_edges.empty?}.add_marks(:fillcolor => 'white')

graph.vertices(FileVertex).add_marks(:style => "filled, rounded") do |v|
  weight = File.size(v.file)/1024
  {:label => "#{File.basename(v.file)} (#{weight} kb)"}
end
graph.vertices(FileVertex){|v| /\.gem$/ =~ v.file}.add_marks(
  :shape => 'box3d', :fillcolor => 'gold'
)
graph.vertices(FileVertex){|v| /^[A-Z]+ (.*)$/ =~ v.label}.add_marks(
  :fillcolor => 'gray25', :fontcolor => 'white'
)
graph.vertices(FileVertex){|v| /\.rb (.*)$/ =~ v.label}.add_marks(
  :shape => 'parallelogram', :fillcolor => 'blue4', :fontcolor => 'white'
)
graph.vertices(FileVertex){|v| /\.rb (.*)$/ =~ v.label}.in_adjacent.add_marks do |v|
  {:fillcolor => 'gold', :fontcolor => 'black'}
end
 
# Save it
File.open(File.join(File.dirname(__FILE__), 'fs2dot.dot'), 'w') do |f|
  f << graph.to_dot
end