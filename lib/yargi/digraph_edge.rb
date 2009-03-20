module Yargi
  class Digraph
    
    #
    # Edge inside a digraph
    #
    # Methods reconnect, index= are provided for Digraph itself and are not 
    # intended to be used directly. Probably unexpectedly, source and target 
    # writers are provided as reconnection shortcuts and can be used by users.
    #
    class Edge
      include Yargi::Markable
      
      # Owning graph
      attr_reader :graph
      alias :digraph :graph
    
      # Index in the vertices list of the owner
      attr_accessor :index
      
      # Source vertex
      attr_reader :source
      
      # Target vertex
      attr_reader :target
    
      # Creates an edge instance
      def initialize(graph, index, source, target)
        @graph, @index = graph, index
        @source, @target = source, target
      end

    
      ### Pseudo-protected section ##########################################
      
      # Reconnects source and target
      def reconnect(source, target)
        @source = source if source
        @target = target if target
      end

      
      ### Query section #######################################################
      
      # Returns edge extremities
      def extremities
        VertexSet[source, target]
      end
      
      # Shortcut for digraph.reconnect(edge, source, nil)
      def source=(source)
        @graph.reconnect(self, source, nil)
      end
    
      # Shortcut for digraph.reconnect(edge, nil, target)
      def target=(target)
        @graph.reconnect(self, nil, target)
      end
      
      
      ### Sort, Hash, etc. section ############################################
      
      # Compares indexes
      def <=>(other)
        return nil unless Edge===other and self.graph==other.graph
        self.index <=> other.index
      end
      
      
      ### Export section ######################################################
      
      # Returns a string representation
      def to_s; "e#{index}:#{source.to_s}->#{target.to_s}" end
          
      # Inspects the vertex
      def inspect; "e#{index}:#{source.inspect}->#{target.inspect}" end
      
    end # class Edge
    
  end
end