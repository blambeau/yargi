require 'delegate'

module Yargi
  
  # Main module of VertexSet and EdgeSet
  class ElementSet < Array
    
    ### Factory section #######################################################
    
    # Creates a VertexSet instance using _elements_ varargs.
    def self.[](*elements)
      ElementSet.new(elements)
    end
    
    ### Array handling ########################################################

    # Same as Array.dup
    def dup() extend_result(super) end
    
    # See Array.compact
    def compact() extend_result(super) end
    
    # See Array.flatten
    def flatten() extend_result(super) end
    
    # See Array.reverse
    def reverse() extend_result(super) end
    
    # See Array.uniq
    def uniq() extend_result(super) end
    
    # See Array.sort
    def sort(&block) extend_result(super(&block)) end
    
    # See Array.concat
    def concat(other) extend_result(super(other)) end
    
    # See Array.clear
    def [](*args)
      result = super(*args)
      Array===result ? extend_result(result) : result 
    end
    
    # See Array.+
    def +(right) extend_result(super(right)) end
    
    # See Array.-
    def -(right) extend_result(super(right)) end
      
    ### Enumerable handling ###################################################
    
    # See Enumerable.each_cons
    def each_cons(n) super(n) {|c| yield extend_result(c)} end
    
    # See Enumerable.each_slice
    def each_slice(n) super(n) {|c| yield extend_result(c)} end
    
    # See Enumerable.select
    def select(&block) extend_result(super(&block)) end
      
    # See Enumerable.find_all
    def find_all(&block) extend_result(super(&block)) end
      
    # See Enumerable.grep
    def grep(pattern, &block)
      greped = super(pattern, &block)
      block_given? ? greped : extend_result(greped)
    end
      
    # See Enumerable.reject
    def partition(&block)
      p = super(&block)
      [extend_result(p[0]), extend_result(p[1])]
    end
      
    # See Enumerable.reject
    def reject(&block) extend_result(super(&block)) end
    
    ### Markable handling #####################################################
    
    # Fired to each element of the group. 
    def tag(*modules)
      self.each {|elm| elm.tag(*modules)}
    end
    
    # Collects result of get_mark invocation on each element of the 
    # group and returns it as an array.
    def get_mark(key)
      self.collect {|elm| elm.get_mark(key)}
    end

    # Fired to each element of the group. Values are duplicated by default. 
    # Put dup to false to avoid this behavior.
    def set_mark(key, value, dup=true)
      self.each {|elm| elm.set_mark(key, (dup and not(Symbol===value)) ? value.dup : value)}
    end
    
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
    
    ### Protected section #####################################################
    protected
        
    # Extends a resulting array with the module. This method is intended
    # to be overrided by specialization of this module.
    def extend_result(result)
      ElementSet.new(result)
    end

  end # class ElementSet
  
end