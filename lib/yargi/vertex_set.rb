module Yargi
  
  # A set of vertices
  class VertexSet < ElementSet
    
    ### Factory section #######################################################
    
    # Creates a VertexSet instance using _elements_ varargs.
    def self.[](*elements)
      VertexSet.new(elements)
    end
    
    ### Protected section #####################################################
    protected
        
    # Extends with VertexSet instead of ElementSet
    def extend_result(result)
      VertexSet.new(result)
    end

  end # module VertexSet

end