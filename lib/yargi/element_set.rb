module Yargi
  
  # Main module of VertexSet and EdgeSet
  module ElementSet
    
    # Fired to each element of the group. 
    def tag(*modules)
      self.each {|elm| elm.tag(*modules)}
    end
    
    # Collects result of get_mark invocation on each element of the 
    # group and returns it as an array.
    def get_mark(key)
      self.collect {|elm| elm.get_mark(key)}
    end

    # If key is an integer, returns the key-th element in this set.
    # Same as get_mark otherwise.
    def [](key)
      return super(key) if Integer===key
      get_mark(key)
    end
    
    # Fired to each element of the group. Values are duplicated by default. 
    # Put dup to false to avoid this behavior.
    def set_mark(key, value, dup=true)
      self.each {|elm| elm.set_mark(key, (dup and not(Symbol===value)) ? value.dup : value)}
    end
    alias :[]= :set_mark
    
    # When _marks_ is provided, the invocation is fired to all group
    # elements. When a block is given, it is called on each element,
    # passing it as argument. If the block returns a hash, that hash
    # is installed as marks on the iterated element. 
    # The two usages (_marks_ and block) can be used conjointly.
    def add_marks(marks=nil)
      self.each {|elm| elm.add_marks(marks)} if marks
      if block_given? 
        self.each do |elm|
          hash = yield elm
          elm.add_marks(hash) if hash
        end
      end
    end
    alias :merge_marks :add_marks
    
  end # module ElementSet
  
end