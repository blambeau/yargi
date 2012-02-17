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
        vertex_count.times do |i|
          vertex = g.add_vertex
          vertex_builder.call(vertex,i) if vertex_builder
        end
        edge_count.times do |i|
          source = g.ith_vertex(Kernel.rand(vertex_count))
          target = g.ith_vertex(Kernel.rand(vertex_count))
          edge = g.connect(source, target)
          edge_builder.call(edge,i) if edge_builder
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

    #
    # Generates a random graph.
    #
    # @param [Integer] vertex_count number of vertices to generate
    # @param [Integer] edge_count number of edges to generate
    # @param [Integer] strip strip the graph (reachability for first vertex)
    # @return [Digraph] a directed graph randomly generated
    #
    # Example:
    #
    #     # Generate a random graph with 20 vertices
    #     # and 60 edges exactly (no stripping)
    #     Digraph.random(20,60,false)
    #
    #     # Even more powerful, r is a Digraph::Random
    #     Digraph.random do |r|
    #       r.vertex_count = 20
    #       r.edge_count = 60
    #       r.strip = false
    #       r.vertex_builder = lambda{|v,i| ... } # as digraph.add_n_vertices
    #       r.edge_builder   = lambda{|e,i| ... } # similarl
    #     end
    #
    def self.random(vertex_count = nil, edge_count = nil, strip = nil)
      r = Random.new{|rand|
        rand.vertex_count = vertex_count if vertex_count
        rand.edge_count = edge_count if edge_count
        rand.strip = strip if strip
      }
      yield(r) if block_given?
      r.execute
    end

  end

end # module Yargi