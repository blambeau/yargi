module Yargi
  
  # A set of vertices
  class VertexSet < ElementSet
    
    ### Factory section #######################################################
    
    # Creates a VertexSet instance using _elements_ varargs.
    def self.[](*elements)
      VertexSet.new(elements)
    end
    
    
    ### Walking section #######################################################
    
    # Returns incoming edges of all vertices of this set
    def in_edges(filter=nil, &block)
      r = self.collect {|v| v.in_edges(filter, &block) }
      EdgeSet.new(r).flatten.uniq
    end
    
    # Returns all back-adjacent vertices reachable from this set
    def in_adjacent(filter=nil, &block)
      r = self.collect {|v| v.in_adjacent(filter, &block) }
      VertexSet.new(r).flatten.uniq
    end
    
    # Returns all outgoing edges of all vertices of this set
    def out_edges(filter=nil, &block)
      r = self.collect {|v| v.out_edges(filter, &block) }
      EdgeSet.new(r).flatten.uniq
    end

    # Returns all forward-adjacent vertices reachable from this set
    def out_adjacent(filter=nil, &block)
      r = self.collect {|v| v.out_adjacent(filter, &block) }
      VertexSet.new(r).flatten.uniq
    end
    
    # Returns all adjacent vertices reachable from this set
    def adjacent(filter=nil, &block)
      (in_adjacent(filter, &block)+out_adjacent(filter, &block)).uniq
    end
    
    
    ### Protected section #####################################################
    protected
        
    # Extends with VertexSet instead of ElementSet
    def extend_result(result)
      VertexSet.new(result)
    end

  end # module VertexSet

end