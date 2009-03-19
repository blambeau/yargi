module Yargi
  class Digraph
    
    # Simple vertex inside a graph
    class Vertex
      include Yargi::Markable
    
      # Owning graph
      attr_reader :graph
      alias :digraph :graph
    
      # Index in the vertices list of the owner
      attr_accessor :index
      
      # Creates a vertex instance
      def initialize(graph, index)
        @graph, @index = graph, index
        @in_edges, @out_edges = [], []
      end
      
      # Returns a copy of the incoming edges list.
      def in_edges
        @in_edges.dup
      end
    
      # Returns a copy of the outgoing edges list.
      def out_edges
        @out_edges.dup
      end
    
      # Adds an incoming edge
      def add_in_edge(edge)
        @in_edges << edge
      end
      
      # Removes an incoming edge
      def remove_in_edge(edge)
        @in_edges.delete(edge)
      end
      
      # Adds an outgoing edge
      def add_out_edge(edge)
        @out_edges << edge
      end
    
      # Removes an outgoing edge
      def remove_out_edge(edge)
        @out_edges.delete(edge)
      end
      
      # Returns a string representation
      def to_s; "V#{index}" end
    
      # Inspects the vertex
      def inspect; "V#{index}" end
    
    end # class Vertex
    
  end
end