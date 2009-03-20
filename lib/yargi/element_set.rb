require 'delegate'

module Yargi
  
  # Main module of VertexSet and EdgeSet
  class ElementSet
    include Enumerable
    
    ### Factory section #######################################################
    
    # Creates a VertexSet instance using _elements_ varargs.
    def self.[](*elements)
      ElementSet.new(elements)
    end
    
    # Creates an element set wth _elements_
    def initialize(elements)
      raise ArgumentError, "Array expected" unless Array===elements
      @elements = elements
    end
    
    ### Array handling ########################################################
    
    # Delegated to the array
    def method_missing(name, *args, &block)
      @elements.send(name, *args, &block)
    end

    # Same as Array.length
    def length() @elements.length() end
    
    # Same as Array.each
    def each(&block) @elements.each(&block) end
    
    # Same as Array.dup
    def dup() extend_result(@elements.dup) end
    
    # Same as Array.clear
    def clear() @elements.clear() end
    
    # See Array.compact
    def compact() extend_result(@elements.compact) end
    
    # See Array.flatten
    def flatten() 
      elms = @elements.collect do |elm|
        case elm
          when Array
            elm
          when ElementSet
            elm.to_a
          else
            elm
        end
      end
      extend_result(elms.flatten) 
    end
    
    # See Array.reverse
    def reverse() extend_result(@elements.reverse) end
    
    # See Array.uniq
    def uniq() extend_result(@elements.uniq) end
    
    # See Array.sort
    def sort(&block) extend_result(@elements.sort(&block)) end
    
    # See Array.concat
    def concat(other) extend_result(@elements.concat(other)) end
    
    # See Array.clear
    def [](*args)
      result = @elements.[](*args)
      Array===result ? extend_result(result) : result 
    end
    
    # See Array.+
    def +(right) extend_result(@elements + (ElementSet===right ? right.to_a : right)) end
    
    # See Array.-
    def -(right) extend_result(@elements - (ElementSet===right ? right.to_a : right)) end
      
    # Converts this set to a real ruby Array instance.
    def to_a() @elements.dup end
    
    # Checks equality
    def ==(other)
      ElementSet===other and self.to_a==other.to_a
    end
    
    ### Enumerable handling ###################################################
    
    # See Enumerable.each_cons
    def each_cons(n) @elements.each_cons(n) {|c| yield extend_result(c)} end
    
    # See Enumerable.each_slice
    def each_slice(n) @elements.each_slice(n) {|c| yield extend_result(c)} end
    
    # See Enumerable.select
    def select(&block) extend_result(@elements.select(&block)) end
      
    # See Enumerable.find_all
    def find_all(&block) extend_result(@elements.find_all(&block)) end
      
    # See Enumerable.grep
    def grep(pattern, &block)
      greped = @elements.grep(pattern, &block)
      block_given? ? greped : extend_result(greped)
    end
      
    # See Enumerable.reject
    def partition(&block)
      p = @elements.partition(&block)
      [extend_result(p[0]), extend_result(p[1])]
    end
      
    # See Enumerable.reject
    def reject(&block) extend_result(@elements.reject(&block)) end
    
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