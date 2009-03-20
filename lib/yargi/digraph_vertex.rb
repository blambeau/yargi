module Yargi
  class Digraph
    
    #
    # Vertex inside a digraph.
    #
    # Methods add_in_edge, remove_in_edge, add_out_edge, remove_out_edge and index= 
    # are provided for Digraph itself and are not intended to be used directly.
    #
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
        @in_edges, @out_edges = EdgeSet[], EdgeSet[]
      end

      
      ### Query section #######################################################
      
      # Returns a copy of the incoming edges list.
      def in_edges(filter=nil, &block)
        @in_edges.filter(filter, &block)
      end
    
      # Returns a copy of the outgoing edges list.
      def out_edges(filter=nil, &block)
        @out_edges.filter(filter, &block)
      end
      
      # Returns all adjacent vertices
      def adjacent(filter=nil, &block)
        (in_adjacent(filter, &block) + out_adjacent(filter, &block)).uniq
      end
      
      # Returns back-adjacent vertices 
      def in_adjacent(filter=nil, &block)
        @in_edges.source.filter(filter, &block)
      end
    
      # Returns forward-adjacent vertices 
      def out_adjacent(filter=nil, &block)
        @out_edges.target.filter(filter, &block)
      end

    
      ### Pseudo-protected section ##########################################
      
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
      
      
      ### Sort, Hash, etc. section ############################################
      
      # Compares indexes
      def <=>(other)
        return nil unless Vertex===other and self.graph==other.graph
        self.index <=> other.index
      end
      
      
      ### Export section ######################################################
      
      # Returns a string representation
      def to_s; "V#{index}" end
    
      # Inspects the vertex
      def inspect; "V#{index}" end
    
    end # class Vertex
    
  end
end