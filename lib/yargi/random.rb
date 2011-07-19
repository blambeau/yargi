module Yargi
  #
  # Random graph generator
  # 
  class Random
    
    # @return [Integer] number of vertices to generate
    attr_accessor :vertex_count
    
    # @return [Proc] proc to call on vertex generation
    attr_accessor :vertex_builder
    
    # @return [Integer] number of edges to generate
    attr_accessor :edge_count
    
    # @return [Proc] proc to call on vertex generation
    attr_accessor :edge_builder
    
    # @returns [Boolean] strip the generated graph to one connex component
    #          reachable from the first vertex?
    attr_accessor :strip
    
    # Creates an algorithm instance
    def initialize
      @vertex_count = 50
      @vertex_builder = nil
      @edge_count = 150
      @edge_builder = nil
      @strip = true
      yield(self) if block_given?
    end
    
    # Executes the random generation
    def execute
      graph = Digraph.new{|g|
        if vertex_builder
          g.add_n_vertices(vertex_count, &vertex_builder)
        else 
          g.add_n_vertices(vertex_count)
        end
        edge_count.times do |i|
          source = g.ith_vertex(Kernel.rand(vertex_count))
          target = g.ith_vertex(Kernel.rand(vertex_count))
          if edge_builder
            g.connect(source, target, &edge_builder)
          else
            g.connect(source, target)
          end
        end
      }
      strip ? _strip(graph) : graph
    end
    
    protected 
    
    def _strip(graph)
      Decorate::DEPTH.execute(graph)
      graph.remove_vertices graph.vertices{|v| v[:depth] == 1.0/0}
      graph
    end
    
  end # class Random
  class Digraph
    def self.random(vertex_count = nil, edge_count = nil)
      r = Random.new{|rand|
        rand.vertex_count = vertex_count if vertex_count
        rand.edge_count = edge_count if edge_count
      }
      yield(r) if block_given?
      r.execute
    end
  end
end # module Yargi