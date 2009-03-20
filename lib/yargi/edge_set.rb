module Yargi
  
  # A set of edges
  class EdgeSet < ElementSet
    
    ### Factory section #######################################################
    
    # Creates a VertexSet instance using _elements_ varargs.
    def self.[](*elements)
      EdgeSet.new(elements)
    end
    
    ### Protected section #####################################################
    protected
        
    # Extends with EdgeSet instead of ElementSet
    def extend_result(result)
      EdgeSet.new(result)
    end

  end # module EdgeSet

end