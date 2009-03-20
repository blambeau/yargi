module Yargi
  
  # A set of edges
  class EdgeSet < ElementSet
    
    ### Factory section #######################################################
    
    # Creates a VertexSet instance using _elements_ varargs.
    def self.[](*elements)
      EdgeSet.new(elements)
    end
    
    ### Walking section #######################################################
    
    # Returns a VertexSet with reachable vertices using the edges of this set.
    def target
      VertexSet.new(self.collect {|e| e.target}).uniq
    end
    alias :targets :target
    
    # Returns a VertexSet with back-reachable vertices using the edges of this 
    # set.
    def source
      VertexSet.new(self.collect {|e| e.source}).uniq
    end
    alias :sources :source
    
    ### Protected section #####################################################
    protected
        
    # Extends with EdgeSet instead of ElementSet
    def extend_result(result)
      EdgeSet.new(result)
    end

  end # module EdgeSet

end